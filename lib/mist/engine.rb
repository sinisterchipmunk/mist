require 'rails'

module Mist
  class Engine < Rails::Engine
    engine_name 'mist'
    isolate_namespace Mist
  end
end
