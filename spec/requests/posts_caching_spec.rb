require 'spec_helper'

describe "Posts cache" do
  before do
    ## NO IDEA why this has to happen, but it corrects a failure when run alongside other tests
    # it seems to be related to class reloading but I don't know why
    get posts_path
    
    ActionController::Base.perform_caching = true
    FileUtils.rm_rf Rails.root.join('tmp/cache')
    Mist.authorize { true }
  end
  
  after do
    ActionController::Base.perform_caching = false
  end
  
  describe "busting" do
    it "should happen when a post is created" do
      Mist::PostSweeper.instance.should_receive(:bust!)
      create :post
    end
    
    describe "with a post already existing" do
      before do
        create :post
      end

      it "should happen when a post is updated" do
        Mist::PostSweeper.instance.should_receive(:bust!)
        p = Mist::Post.last
        p.content += "one"
        p.save
      end
      
      it "should happen when a post is deleted" do
        Mist::PostSweeper.instance.should_receive(:bust!)
        Mist::Post.last.destroy
      end
    end
  end
  
  # now handled in cucumber
  
  # describe "GET /posts/show" do
  #   before do
  #     post posts_path, :post => attributes_for(:post)
  #     @post = Mist::Post.last
  #     show_post_cache_path.should_not be_cached # sanity check
  #   end
  #   
  #   it "should prime the cache" do
  #     get post_path(@post.id)
  #     show_post_cache_path.should be_cached
  #   end
  #   
  #   describe "after priming the cache" do
  #     before { get post_path(@post.id) }
  # 
  #     it "should not be busted by a new post" do
  #       post posts_path, :post => attributes_for(:post).merge(:title => "another")
  #       show_post_cache_path.should be_cached
  #     end
  # 
  #     it "should be busted by updating the same post" do
  #       put post_path(@post.id), :post => { :content => "#{@post.content}1" }
  #       show_post_cache_path.should_not be_cached
  #     end
  # 
  #     it "should not be busted by updating a different post" do
  #       another = create :post, :title => "another"
  #       put post_path(another.id), :post => { :content => "#{another.content}1" }
  #       show_post_cache_path.should be_cached
  #     end
  # 
  #     it "should be busted by destroying the same post" do
  #       delete post_path(@post.id)
  #       show_post_cache_path.should_not be_cached
  #     end
  # 
  #     it "should not be busted by destroying a different post" do
  #       another = create :post, :title => 'another'
  #       delete post_path(another.id)
  #       show_post_cache_path.should be_cached
  #     end
  #   end
  # end
  # 
  # describe "GET /posts/new" do
  #   before { posts_cache_path(:action => 'new').should_not be_cached } # sanity check
  #   
  #   # it's never cached because of the form's auth token
  #   it "should not prime the cache" do
  #     get new_post_path
  #     posts_cache_path(:action => 'new').should_not be_cached
  #   end
  # end
  # 
  # describe "GET /posts/feed" do
  #   before { posts_feed_cache_path.should_not be_cached } # sanity check
  #   
  #   it "should prime the cache" do
  #     get feed_posts_path(:format => 'atom')
  #     posts_feed_cache_path.should be_cached
  #   end
  #   
  #   it "should be busted by a new post" do
  #     get feed_posts_path(:format => 'atom')
  #     post posts_path, :post => attributes_for(:post)
  #     posts_feed_cache_path.should_not be_cached
  #   end
  # end
  # 
  # describe "GET /posts" do
  #   before { posts_cache_path.should_not be_cached } # sanity check
  #
  #   describe "when not logged in" do
  #     it "should prime the cache" do
  #       get posts_path
  #       posts_cache_path.should be_cached
  #     end
  #     
  #     it "should be busted by a new post" do
  #       get posts_path
  #       post posts_path, :post => attributes_for(:post)
  #       posts_cache_path.should_not be_cached
  #     end
  #   end
  #   
  #   describe "when logged in" do
  #     before { Mist.authorize { true } }
  #     before { posts_cache_path(:admin => true).should_not be_cached }
  #     
  #     it "should not use the public cache" do
  #       get posts_path
  #       posts_cache_path.should_not be_cached
  #     end
  #     
  #     it "should prime the cache" do
  #       get posts_path
  #       posts_cache_path(:admin => true).should be_cached
  #     end
  #     
  #     it "should be busted by a new post" do
  #       get posts_path
  #       post posts_path, :post => attributes_for(:post)
  #       posts_cache_path(:admin => true).should_not be_cached
  #     end
  #   end
  # end
  #
end
