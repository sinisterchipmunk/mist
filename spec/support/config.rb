def fixture(name)
  File.read(File.expand_path(File.join("../fixtures", name), File.dirname(__FILE__)))
end

module MistControllerSpecOverrides
  def self.included(base)
    base.class_eval do
      unless instance_methods.include?(:__get) || instance_methods.include?('__get')
        %w(get post put delete).each do |m|
          eval <<-end_code, binding, __FILE__, __LINE__ + 1
            alias __#{m} #{m}
          
            def #{m}(action, parameters = {}, session = nil, flash = nil)
              __#{m}(action, parameters.merge(:use_route => :mist), session, flash)
            end
          end_code
        end
      end
    end
  end
end

module MistViewRouteHelpers
  def self.included(base)
    base.helper Mist::Engine.routes.url_helpers
  end
end

RSpec.configure do |config|
  config.before do
    FileUtils.rm_rf Mist.repository_location if File.directory?(Mist.repository_location)
    FileUtils.rm_rf Rails.application.root.join('tmp/cache') if File.directory?(Rails.application.root.join('tmp/cache'))
    Mist.reload_repository!
    Mist.reset_authorizations!
  end
  
  config.include FactoryGirl::Syntax::Methods
  config.include CacheHelpers, :type => :request
  config.include MistControllerSpecOverrides, :type => :controller
  config.include Mist::Engine.routes.url_helpers
  config.include MistViewRouteHelpers, :type => :view
end
