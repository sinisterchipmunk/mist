class Mist::ViewsGenerator < Rails::Generators::Base
  source_root File.expand_path('../../..', File.dirname(__FILE__))
  
  def copy_views
    directory 'app/views/mist'
  end
  
  def install_assets
    directory 'app/assets'
  end
end
