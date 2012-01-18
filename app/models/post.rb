require_dependency 'mist/permalink'
require_dependency 'mist/git_model'
require_dependency "mist/code_example_parser"

class Post < Mist::GitModel
  include Mist::Permalink

  validates_presence_of :title
  validates_presence_of :content
  
  validate do |record|
    if record.new_record? && self.class.exist?(record.id)
      record.errors.add :title, 'has already been taken'
    end
  end
  
  timestamps
  attribute :content
  attribute :title
  attribute :published_at
  attribute :gist_id
  attribute :popularity, :default => 0
  
  before_validation { |r| r.id = permalink(r.title) unless r.title.blank? }
  after_validation :update_gist_if_necessary
  after_save :update_meta_popularity
  after_initialize :load_code_examples_from_gist
  after_destroy :destroy_gist
  
  def self.most_popular(count)
    self[:popular_posts].sort { |(a_post_id, a_popularity), (b_post_id, b_popularity)|
      -(a_popularity.to_i <=> b_popularity.to_i) # invert <=> so that result is descending order
    }.collect { |(post_id, popularity)| find post_id, :popularity => popularity }.reject { |i| i.nil? }
  end
  
  def update_meta_popularity
    if popularity_changed? || new_record?
      self.class[:popular_posts][id] = popularity
      self.class.save_meta_data :popular_posts
    end
  end
  
  def title=(value)
    attributes[:title] = value
  end
  
  def published?
    !published_at.blank?
  end
  
  def draft?
    !published?
  end
  
  def publish
    self.published_at = Time.now unless published?
  end
  
  def unpublish
    self.published_at = nil
  end
  
  def published=(bool)
    bool ? publish : unpublish
  end
  
  def content=(c)
    attributes[:content] = c.gsub(/\r/, "")
  end
  
  def generated_gist_description
    'Code examples for "%s" - %s' % [title, url]
  end
  
  def gist
    @gist ||= begin
      if gist_id.blank?
        if has_code_examples?
          ActiveGist.new(:description => generated_gist_description, :public => true)
        else
          nil
        end
      else
        begin
          ActiveGist.find(gist_id)
        rescue RestClient::ResourceNotFound
          self.gist_id = nil
          nil
        end
      end
    end
  end
  
  def content_as_html
    GitHub::Markup.render("#{title}.markdown", content_with_embedded_gists).html_safe
  end
  
  def content_as_html_preview
    # just take to the first blank line -- that's probably the first paragraph
    # TODO make this smarter by including more than 1 paragraph if it's short, or by omitting headers
    first_paragraph = /\A(.+?)(\n\n|\n    |\z)/m.match(content.gsub(/\r/, ''))
    GitHub::Markup.render("#{title}.markdown", first_paragraph[1]).html_safe
  end
  
  def content_with_embedded_gists
    # by using gist_id directly we can avoid hitting the Gist API every time the
    # post is rendered.
    
    return content.dup if gist_id.blank?
    
    template = '<script src="https://gist.github.com/__ID__.js?file=__FILENAME__"></script>'
    template['__ID__'] = gist_id.to_s
    
    content.dup.tap do |result|
      # process last example first, so that changes to result don't taint offsets
      code_examples.reverse.each do |example|
        result[example.offset] = template.sub(/__FILENAME__/, example.filename) + "\n"
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
  
  # Assigns the file contents of each file in the gist according to what's found in
  # #content. Does not save the gist. Returns the list of files themselves.
  def set_gist_data
    gist.description = generated_gist_description
    gist.files.keys.each { |filename| gist.files[filename] = nil }
    code_examples.each do |example|
      gist.files[example.filename] = { :content => example }
    end
    gist.files
  end
  
  def url(options = {})
    Mist::Application.routes.url_helpers.post_path(id, options.reverse_merge(:only_path => false))
  end
  
  def update_gist_if_necessary
    return unless errors.empty?
    
    if has_code_examples?
      set_gist_data
      
      if gist.changed?
        errors.add(:gist, "could not be saved: #{gist.errors.full_messages.join('; ')}") unless gist.save
      end

      self.gist_id = gist.id
    else
      # no code examples, delete gist
      gist.destroy if gist && gist.persisted?
    end
  end
  
  def destroy_gist
    gist.destroy if gist && gist.persisted?
  end
end
