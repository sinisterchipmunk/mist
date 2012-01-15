def fixture(name)
  File.read(File.expand_path(File.join("../fixtures", name), File.dirname(__FILE__)))
end

RSpec.configure do |config|
  config.before do
    FileUtils.rm_rf Mist.repository_location if File.directory?(Mist.repository_location)
    Mist.reload_repository!
  end
  
  config.include FactoryGirl::Syntax::Methods
end
