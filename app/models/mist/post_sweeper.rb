class Mist::PostSweeper < ActionController::Caching::Sweeper
  observe Mist::Post
  
  def after_save(post)
    bust! post
  end
  
  def after_destroy(post)
    bust! post
  end
  
  def bust!(post)
    expire_action :action => 'index'
    expire_action :action => 'index', :admin => true
    expire_page   :action => 'feed', :format => 'atom'
    expire_page   :action => 'show', :id => post.id
  end
end
