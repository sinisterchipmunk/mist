class Mist::SetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../../..', File.dirname(__FILE__))
  
  def copy_views
    copy_file 'app/views/layouts/mist/posts.html.erb'
    directory 'app/views/mist'
  end
  
  def install_assets
    directory 'app/assets'
  end
  
  def create_initializer
    copy_file File.expand_path('templates/initializer.rb', File.dirname(__FILE__)),
              'config/initializers/mist.rb'
  end
end
