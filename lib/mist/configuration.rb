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
  
  def reset_authorizations!
    authorizations.clear
  end
  
  def authorizations
    @authorizations ||= {}.with_indifferent_access
  end
  
  def commit_meta_data
    @commit_meta_data = true if @commit_meta_data.nil?
  end
  
  def commit_meta_data=(a)
    @commit_meta_data = a
  end
  
  # Register a block to be invoked whenever Mist needs to know if a user is allowed
  # to perform some action, such as :create_post, :edit_post, :view_post, :destroy_post,
  # or :all.
  #
  #   Mist.authorize { |controller| ... }               # invoke for any action not otherwise registered
  #   Mist.authorize(:all) { |controller| ... }         # same as above
  #   Mist.authorize(:create_post) { |controller| ... } # use this block only for :create_post
  #
  # By default, all authorization requests will return false (denied).
  #
  def authorize(*types, &block)
    raise ArgumentError, "Expected a block which will be evaluated at runtime" unless block_given?
    types.push :all if types.empty?
    types.each { |type| authorizations[type] = block }
  end
  
  # Invokes the blocks registered by Mist::Configuration#authorize to see if the specified
  # action is authorized. Passes *args into the block.
  def authorized?(action, *args)
    if authorizations.key?(action) then authorizations[action].call *args
    elsif authorizations.key?(:all) then authorizations[:all].call *args
    else nil
    end
  end
end
