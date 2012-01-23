require 'git'
require 'github/markup'
require 'active_gist'

module Mist
  require 'mist/engine'
  require 'mist/configuration'
  require 'mist/repository'
  require 'mist/version'
  require 'mist/permalink'
  require 'mist/git_model'
  require "mist/code_example_parser"
  
  extend Mist::Configuration
  extend Mist::Repository
  
  class << self
    delegate :log, :to => :repository
  end
end
