require_dependency 'mist/permalink'
require_dependency 'mist/git_model'
require_dependency "mist/code_example_parser"

class Post < Mist::GitModel
  TAG_DELIM = /\s*,\s*/
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
  attribute :tags, :default => []
  
  before_validation { |r| r.id = permalink(r.title) unless r.title.blank? }
  after_validation :update_gist_if_necessary
  after_save :update_meta
  after_initialize :load_code_examples_from_gist
  after_destroy :destroy_gist
  
  def self.load_existing_with_attribute(attribute_name, array)
    array.collect { |(post_id, attribute_value)| find post_id, attribute_name => attribute_value }.reject { |i| i.nil? }
  end
  
  def self.most_popular(count)
    # invert <=> so that result is descending order
    load_existing_with_attribute :popularity, self[:popular_posts].sort { |a, b| -(a[1].to_i <=> b[1].to_i) }
  end
  
  def self.recently_published(count)
    # invert <=> so that result is descending order
    load_existing_with_attribute :published_at, self[:published_at].sort { |a, b| -(a[1] <=> b[1]) }
  end
  
  def self.matching_tags(tags)
    matches = self[:tags].inject({}) { |h,(k,v)| ((t = v.split(TAG_DELIM)) & tags).size > 0 ? h[k] = t : nil; h }
    load_existing_with_attribute :tags, matches.sort { |a, b| -((a[1] & tags).size <=> (b[1] & tags).size) }
  end
  
  def similar_posts(max_count = nil)
    self.class.matching_tags(tags).tap do |matching|
      matching.delete self # similar does not mean identical :)
      matching.pop while max_count && matching.length > max_count
    end
  end
  
  def tags=(t)
    if t.kind_of?(String)
      attributes[:tags] = t.split(TAG_DELIM)
    else
      attributes[:tags] = t
    end
  end
  
  def update_meta
    if popularity_changed? || new_record?
      self.class[:popular_posts][id] = popularity
      self.class.save_meta_data :popular_posts
    end
    
    if published_at_changed?
      if published_at.blank?
        self.class[:published_at].delete id
      else
        self.class[:published_at][id] = published_at
      end
      self.class.save_meta_data :published_at
    end
    
    if tags.empty?
      self.class[:tags].delete id
    else
      self.class[:tags][id] = tags.join(', ')
    end
    self.class.save_meta_data :tags
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
