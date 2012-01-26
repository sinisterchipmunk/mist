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
    
    # Returns an array of all possible actions which Mist will authorize against
    # at one point or another
    def authorized_actions
      [ :create_post, :edit_post, :destroy_post, :view_drafts ]
    end
  end
end
