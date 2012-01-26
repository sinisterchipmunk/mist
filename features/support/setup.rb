require 'fakeweb'

Before do
  FakeWeb.allow_net_connect = false
  FileUtils.rm_rf Mist.repository_location
  FileUtils.rm_rf Rails.root.join('tmp/cache')
  Mist.reload_repository!
  Mist.reset_authorizations!
  Mist.authorize { |controller| true } # user is an admin by default
  
  path = File.expand_path('../../spec/dummy_rails_app/public/posts.html', File.dirname(__FILE__))
  FileUtils.rm path if File.exist?(path)
  path = File.join(File.dirname(path), 'posts')
  FileUtils.rm_rf path
end
