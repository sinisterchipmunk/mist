require_dependency 'mist/permalink'
require_dependency 'mist/git_model'

class Post < Mist::GitModel
  include Mist::Permalink

  validates_presence_of :title
  validate :uniqueness_of_title
  validates_presence_of :content
  
  timestamps
  attribute :content
  attribute :title
  attribute :published_at
  
  def title=(value)
    self.id = permalink(value)
    attributes[:title] = value
  end

  def uniqueness_of_title
    unless id.blank?
      if id_changed? and Post.find(id)
        errors.add :title, "has already been taken"
      end
    end
  end
end
