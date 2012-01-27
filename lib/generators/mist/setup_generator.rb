class Mist::SetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../../..', File.dirname(__FILE__))
  
  def copy_views
    copy_file 'app/views/layouts/mist/posts.html.erb'
  end
  
  def install_assets
    copy_file template_path('mist.js.coffee'), 'app/assets/javascripts/mist.js.coffee'
    copy_file template_path('mist.css.scss'),  'app/assets/stylesheets/mist.css.scss'
  end
  
  def create_initializer
    copy_file template_path('initializer.rb'), 'config/initializers/mist.rb'
  end
  
  private
  def template_path(relative_path)
    File.expand_path(File.join('templates', relative_path), File.dirname(__FILE__))
  end
end
