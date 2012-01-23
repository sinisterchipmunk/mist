module CacheHelpers
  ActionController::Base.public_class_method :page_cache_path
  
  class CacheMatcher
    def initialize(method = :cached?)
      @method = method
    end
    
    def matches?(actual)
      (@actual = actual).send @method
    end
    
    def failure_message
      "Expected path #{@actual.inspect} to be cached, but was not"
    end
    
    def negative_failure_message
      "Expected path #{@actual.inspect} not to be cached, but it was"
    end
  end
  
  def be_cached
    CacheMatcher.new
  end
  
  def be_action_cached
    CacheMatcher.new(:action_cached?)
  end
  
  def be_page_cached
    CacheMatcher.new(:page_cached?)
  end

  def posts_cache_path(options = {})
    ActionController::Caching::Actions::ActionCachePath.new(controller, options.merge(:only_path => true)).path
  end
  
  def show_post_cache_path
    posts_cache_path :action => 'show', :id => @post.id
  end
  
  def posts_feed_cache_path
    posts_cache_path :action => 'feed', :format => 'atom'
  end
  
  def self.included(base)
    base.class_eval do
      before do
        path = File.dirname(File.expand_path(ActionController::Base.page_cache_path('/posts/index')))
        FileUtils.rm_rf path
      end
    end
  end
end

class String
  def action_cached?
    Rails.cache.exist?(File.join 'views', 'www.example.com', self)
  end

  def page_cached?
    File.exists? ActionController::Base.page_cache_path(self)
  end
  
  def cached?
    action_cached? || page_cached?
  end
end
