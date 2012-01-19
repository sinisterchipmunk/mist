Mist::Application.routes.draw do
  # we can use scope if we don't want 'mist_' prefix,
  # but I think having the prefix is probably safer
  # scope :module => "mist" do
  
  namespace :mist, :path => '' do
    resources :posts, :path => '' do
      collection do
        get :feed
      end
    end
  end
end
