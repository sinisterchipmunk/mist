module CacheHelpers
  ActionController::Base.public_class_method :page_cache_path
end

class String
  def action_cached?
    Rails.cache.exist?("views/www.example.com#{self}")
  end

  def page_cached?
    File.exists? ActionController::Base.page_cache_path(self)
  end
  
  def cached?
    action_cached? || page_cached?
  end
end
