require 'spec_helper'

describe Mist::PostsController do
  # This should return the minimal set of attributes required to create a valid
  # Post. As you add validations to Post, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    attributes_for :post
  end
  
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PostsController. Be sure to keep this updated too.
  def valid_session
    {}
  end
  
  describe "GET feed .rss" do
    it "redirects to feed .atom" do
      get :feed, {:format => :rss}, valid_session
      response.should redirect_to(feed_posts_path :format => :atom)
    end
  end

  describe "GET index" do
    it "assigns all posts as @posts" do
      post = create :post, :published_at => Time.now
      get :index, {}, valid_session
      assigns(:posts).should eq([post])
    end
  end

  describe "GET show" do
    it "assigns the requested post as @post" do
      post = Mist::Post.create! valid_attributes
      get :show, {:id => post.to_param}, valid_session
      assigns(:post).should eq(post)
    end
    
    it "increments the post popularity" do
      post = Mist::Post.create! valid_attributes
      popularity = post.popularity
      get :show, {:id => post.to_param}, valid_session
      popularity.should be < Mist::Post.find(post.id).popularity
    end
  end

  describe "GET new" do
    it "assigns a new post as @post" do
      get :new, {}, valid_session
      assigns(:post).should be_a_new(Mist::Post)
    end
  end

  describe "GET edit" do
    it "assigns the requested post as @post" do
      post = Mist::Post.create! valid_attributes
      get :edit, {:id => post.to_param}, valid_session
      assigns(:post).should eq(post)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Post" do
        expect {
          post :create, {:post => valid_attributes}, valid_session
        }.to change(Mist::Post, :count).by(1)
      end

      it "assigns a newly created post as @post" do
        post :create, {:post => valid_attributes}, valid_session
        assigns(:post).should be_a(Mist::Post)
        assigns(:post).should be_persisted
      end

      it "redirects to the created post" do
        post :create, {:post => valid_attributes}, valid_session
        response.should redirect_to(Mist::Post.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved post as @post" do
        # Trigger the behavior that occurs when invalid params are submitted
        Mist::Post.any_instance.stub(:save).and_return(false)
        post :create, {:post => {}}, valid_session
        assigns(:post).should be_a_new(Mist::Post)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Mist::Post.any_instance.stub(:save).and_return(false)
        post :create, {:post => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested post" do
        post = Mist::Post.create! valid_attributes
        # Assuming there are no other posts in the database, this
        # specifies that the Mist::Post created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Mist::Post.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => post.to_param, :post => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested post as @post" do
        post = Mist::Post.create! valid_attributes
        put :update, {:id => post.to_param, :post => valid_attributes}, valid_session
        assigns(:post).should eq(post)
      end

      it "redirects to the post" do
        post = Mist::Post.create! valid_attributes
        put :update, {:id => post.to_param, :post => valid_attributes}, valid_session
        response.should redirect_to(post)
      end
    end

    describe "with invalid params" do
      it "assigns the post as @post" do
        post = Mist::Post.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Mist::Post.any_instance.stub(:save).and_return(false)
        put :update, {:id => post.to_param, :post => {}}, valid_session
        assigns(:post).should eq(post)
      end

      it "re-renders the 'edit' template" do
        post = Mist::Post.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Mist::Post.any_instance.stub(:save).and_return(false)
        put :update, {:id => post.to_param, :post => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested post" do
      post = Mist::Post.create! valid_attributes
      expect {
        delete :destroy, {:id => post.to_param}, valid_session
      }.to change(Mist::Post, :count).by(-1)
    end

    it "redirects to the posts list" do
      post = Mist::Post.create! valid_attributes
      delete :destroy, {:id => post.to_param}, valid_session
      response.should redirect_to(posts_path)
    end
  end

end
