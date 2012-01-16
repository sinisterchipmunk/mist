module PostsHelper
  def authorized_link(type, *link_options)
    if Mist.authorized?(type, controller)
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
end
