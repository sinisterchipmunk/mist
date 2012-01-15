require_dependency 'mist/permalink'
require_dependency 'mist/git_model'

class Post < Mist::GitModel
  include Mist::Permalink

  validates_presence_of :title
  validates_presence_of :content
  
  validate do |record|
    if record.new_record? && self.class.find(record.id)
      record.errors.add :title, 'has already been taken'
    end
  end
  
  timestamps
  attribute :content
  attribute :title
  attribute :published_at
  attribute :gist_id
  
  before_save :update_gist_if_necessary
  after_initialize :load_code_examples_from_gist
  
  
  def title=(value)
    self.id = permalink(value)
    attributes[:title] = value
  end
  
  def gist
    @gist ||= begin
      if gist_id.blank?
        if has_code_examples?
          ActiveGist.new(:description => "Code examples for blog post: #{title}", :public => true)
        else
          nil
        end
      else
        ActiveGist.find(gist_id)
      end
    end
  end
  
  def content_as_html
    GitHub::Markup.render("#{title}.markdown", content_with_embedded_gists).html_safe
  end
  
  def content_with_embedded_gists
    return content.dup unless gist && gist.persisted?
    
    template = '<script src="https://gist.github.com/__ID__.js?file=__FILENAME__"></script>'
    template['__ID__'] = gist.id.to_s
    
    content.dup.tap do |result|
      # process last example first, so that changes to result don't taint offsets
      code_examples.reverse.each do |example|
        result[example.offset] = template.sub(/__FILENAME__/, example.filename)
      end
    end
  end
  
  def has_code_examples?
    code_examples.length > 0
  end
  
  def code_examples
    Mist::CodeExampleParser.new(content).examples
  end
  
  def load_code_examples_from_gist
    # p gist
    if gist && gist.persisted?
      self.content = self.content.dup.tap do |result|
        code_examples.reverse.each do |example|
          if gist.files[example.filename]
            lines = gist.files[example.filename][:content].split("\n")
            lines.unshift "    file: #{example.filename}"
            result[example.offset] = lines.join("\n    ") + "\n"
          end
        end
      end
    end
  end
  
  def update_gist_if_necessary
    if has_code_examples?
      # mark all files for deletion, we'll effectively undo this below
      gist.files.send(:hash).each { |key, info| gist.files[key] = nil }
      
      code_examples.each_with_index do |example, index|
        example_file = gist.files[example.filename] ||= {}
        example_file[:content] = example
      end
      
      if gist.changed?
        errors.add(:gist, "could not be saved: #{gist.errors.full_messages.join('; ')}") unless gist.save
      end
      
      self.gist_id = gist.id
    else
      # no code examples, delete gist
      gist.destroy if gist && gist.persisted?
    end
  end
end
