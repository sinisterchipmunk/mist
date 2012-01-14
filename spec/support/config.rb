RSpec.configure do |config|
  config.before do
    FileUtils.rm_rf Mist.repository_location if File.directory?(Mist.repository_location)
    Mist.reload_repository!
  end
  
  config.include FactoryGirl::Syntax::Methods
end
