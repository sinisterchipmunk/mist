require "spec_helper"

describe Mist::PostsController do
  describe "routing" do

    it "routes to #index" do
      get("/mist/posts").should route_to("mist/posts#index")
    end

    it "routes to #new" do
      get("/mist/posts/new").should route_to("mist/posts#new")
    end

    it "routes to #show" do
      get("/mist/posts/1").should route_to("mist/posts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/mist/posts/1/edit").should route_to("mist/posts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/mist/posts").should route_to("mist/posts#create")
    end

    it "routes to #update" do
      put("/mist/posts/1").should route_to("mist/posts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/mist/posts/1").should route_to("mist/posts#destroy", :id => "1")
    end

  end
end
