class Mist::PostSweeper < ActionController::Caching::Sweeper
  observe Mist::Post
  
  def after_save(post)
    bust! post
  end
  
  def after_destroy(post)
    bust! post
  end
  
  def before_save(post)
    @tags_were = post.tags_was
  end
  
  def bust!(post)
    expire_page :action => 'feed', :format => 'atom'

    touched = touched_posts post
    each_combo(Mist.authorized_actions) do |options|
      options.keys.each { |key| options.delete(key) unless options[key] }

      expire_page options.merge(:action => 'index')
      bust_post! post, options
      touched.each { |p| bust_post! p, options }
    end
  end
  
  def bust_post!(post, options)
    expire_action   options.merge(:action => 'show', :id => post.id)
  end
  
  def touched_posts(post)
    (post.similar_posts | Mist::Post.matching_tags(@tags_were)).tap { |a| a.delete post }
  end
  
  private
  def each_combo(keys)
    len = keys.length
    flags = 0 # start with all off / false
    combos = []
    
    # yields a single combination
    process = proc do
      options = ActiveSupport::OrderedHash.new
      for i in 0...len
        flag = (flags >> i) & 1
        options[keys[i]] = (flag == 1)
      end
      combos << options
      yield options if block_given?
    end
    
    # iterate through all combos and yield them one at a time
    while ((flags >> len) & 1) == 0
      process.call
      flags += 1
    end
    
    # return combos
    combos
  end
end
