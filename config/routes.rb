Mist::Engine.routes.draw do
  resources :posts, :path => '' do
    collection do
      get :feed
    end
  end
end
