class Post < ActiveRecord::Base
  validates_presence_of :title
  validates_uniqueness_of :title
  validates_presence_of :content
  
  before_create do |record|
    record.save_content_file
    record.commit_content_file "Post created"
  end
  
  attr_writer :content
  
  def content
    @content || if new_record?
      nil
    else
      File.read content_path
    end
  end
  
  def permalink
    title.underscore.gsub(/[^a-zA-Z0-9\.]/, '-')
  end
  
  def path
    Mist.repository_location.join('posts', permalink)
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
  
  def commit_content_file(commit_message)
    Mist.repository.add content_path
    Mist.repository.commit commit_message
  end
end
