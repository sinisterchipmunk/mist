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
  
  def title=(value)
    self.id = permalink(value)
    attributes[:title] = value
  end
end
