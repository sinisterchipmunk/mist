module Mist::Configuration
  def repository_location
    @respository_location ||= default_repository_location
  end
  
  def repository_location=(dir)
    @respository_location = dir
  end
  
  def default_repository_location
    Rails.root.join("db/mist.repo.#{Rails.env}")
  end
end
