require 'spec_helper'

describe "Posts caching" do
  before do
    ## NO IDEA why this has to happen, but it corrects a failure when run alongside other tests
    get posts_path
    
    ActionController::Base.perform_caching = true
    FileUtils.rm_rf Rails.root.join('tmp/cache')
  end
  
  after do
    ActionController::Base.perform_caching = false
  end
  
  describe "GET /posts" do
    describe "when not logged in" do
      def posts
        File.join Mist::Engine.routes.url_helpers.posts_path, 'index'
      end
      
      before { posts.should_not be_cached } # sanity check
      
      it "should prime the cache" do
        get posts_path
        posts.should be_cached
      end
      
      it "should be busted by a new post" do
        get posts_path
        post posts_path, :post => attributes_for(:post)
        posts.should_not be_cached
      end
    end
  end
end
