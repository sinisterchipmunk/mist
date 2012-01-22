class Mist::PostSweeper < ActionController::Caching::Sweeper
  observe Mist::Post
  
  def after_save(post)
    expire_action :action => 'index'
    # expire_page feed_posts_path
    # expire_page post_path(post.id)
    # # fixme NOT SAFE for memcached
    # Rails.cache.delete_matched /^mist\/posts/
  end
end
