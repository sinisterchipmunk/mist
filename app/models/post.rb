require_dependency 'mist/permalink'

class Post < ActiveRecord::Base
  include Mist::Permalink
  
  validates_presence_of :title
  validates_uniqueness_of :title
  validates_presence_of :content
  before_create :create_filesystem
  before_update :update_filesystem
  
  attr_writer :content
  
  def content
    @content ||= content_was
  end
  
  def content_was
    @content_was ||= if new_record?
      nil
    else
      File.read content_path
    end
  end
  
  def content_changed?
    content != content_was
  end
  
  def path
    Mist.repository_location.join('posts', permalink(title))
  end
  
  def path_was
    Mist.repository_location.join('posts', permalink(title_was))
  end
  
  def content_path
    path.join 'CONTENT'
  end
  
  def save_content_file
    FileUtils.mkdir_p path
    File.open(content_path, "w") do |f|
      f.print content
    end
  end
  
  def commit_message
    if new_record?
      "Post created"
    else
      "Post updated"
    end
  end
  
  def commit(commit_message = self.commit_message)
    Mist.repository.add content_path
    Mist.repository.commit commit_message
  end
  
  # Called when an existing record is about to be updated
  def update_filesystem
    should_commit = false
    
    if title_changed?
      Mist.repository.lib.mv path_was, path
      should_commit = true
    end
    
    if content_changed?
      save_content_file
      should_commit = true
    end

    commit if should_commit
  end
  
  # Called when a new record is about to be created
  def create_filesystem
    save_content_file
    commit
  end
end
