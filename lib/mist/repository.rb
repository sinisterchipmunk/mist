require 'git'

module Mist::Repository
  def repository
    @repository ||= begin
      if File.directory? Mist.repository_location.join('.git')
        Git.open(Mist.repository_location.to_s, :log => Rails.logger)
      else
        Git.init(Mist.repository_location.to_s, :log => Rails.logger)
      end
    end
  end
  
  def reload_repository!
    @repository = nil
  end
end
