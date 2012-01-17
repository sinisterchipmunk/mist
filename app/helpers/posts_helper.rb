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
    }.join
  end
end
