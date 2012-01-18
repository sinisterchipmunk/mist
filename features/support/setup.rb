require 'fakeweb'

Before do
  FakeWeb.allow_net_connect = false
  FileUtils.rm_rf Mist.repository_location
  Mist.reload_repository!
  Mist.reset_authorizations!
  Mist.authorize { |controller| true } # user is an admin by default
end
