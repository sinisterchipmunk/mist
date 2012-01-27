require 'rails'

module Mist
  class Engine < Rails::Engine
    engine_name 'mist'
    isolate_namespace Mist
    
    initializer "mist.assets" do |app|
      app.config.assets.precompile += ['mist_core.js', 'mist_core.css', 'mist.js', 'mist.css']
    end
  end
end
