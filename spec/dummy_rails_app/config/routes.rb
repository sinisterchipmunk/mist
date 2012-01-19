Mist::Application.routes.draw do
  mount Mist::Engine => "/posts", :as => "mist"
end
