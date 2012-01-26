ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy_rails_app/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl_rails'

ActionController::Base.perform_caching = false

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.before do
    ActionController::Base.perform_caching = false
  end
end

Dir[File.expand_path('factories/**/*.rb', File.dirname(__FILE__))].each { |f| require f }
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[File.expand_path('support/**/*.rb', File.dirname(__FILE__))].each { |f| require f }
