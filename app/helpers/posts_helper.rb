module PostsHelper
  def authorized_link(type, *link_options)
    if authorized? type
      link_to *link_options
    else
      ""
    end
  end
  
  def authorized_links(separator, *link_options)
    link_options.collect { |link_args| authorized_link(*link_args) }.reject { |a| a.blank? }.join(separator).html_safe
  end
  
  def admin_link_separator
    '&nbsp;&bull;&nbsp;'.html_safe
  end
  
  def authorized?(type)
    Mist.authorized? type, controller
  end
  
  def render_posts
    preview = false
    @posts.collect { |post|
      if post.published? || authorized?(:view_drafts)
        render(:partial => 'post', :locals => { :post => post, :preview => preview }).tap do
          preview = true
        end
      else
        ""
      end
    }.join.html_safe
  end
  
  def recent_posts(count = 5)
    @recent_posts ||= {}
    @recent_posts[count] ||= begin
      # without SQL, we don't have access to conveniences like Post.where(:published),
      # so instead just find 2x count and return those that are published.
      result = Post.recently_published count*2
      result = result[0...count] if result.length > count
      result
    end
  end
  
  def popular_posts(count = 5)
    # same as recent posts -- get twice as many and filter out the extras
    @popular_posts ||= {}
    @popular_posts[count] ||= begin
      result = Post.most_popular(count*2).select { |post| post.published? }
      result = result[0...count] if result.length > count
      result
    end
  end
end
