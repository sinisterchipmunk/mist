class Mist::PostsController < ApplicationController
  # caches_action :index, :cache_path => proc { cache_path }
  caches_page :feed
  caches_page :index, :cache_path => proc { cache_path }
  caches_action :show, :cache_path => proc { cache_path }
  before_filter :bump_post_popularity, :only => :show
  cache_sweeper Mist::PostSweeper
  
  # GET /posts
  # GET /posts.json
  def index
    if Mist.authorized? :view_drafts, self
      @posts = Mist::Post.last(20)
    else
      @posts = Mist::Post.recently_published(20)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @posts }
    end
  end
  
  # GET /posts/feed
  def feed
    respond_to do |format|
      format.atom do
        @title = Mist.title
        @posts = Mist::Post.all_by_publication_date
        unless @posts.empty?
          @updated = @posts.inject(@posts.first.updated_at) do |date, post|
            date > post.updated_at ? date : post.updated_at
          end
        end
        render :layout => false
      end
      format.rss { redirect_to feed_posts_path(:format => :atom), :status => :moved_permanently }
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post ||= Mist::Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    redirect_to posts_path and return unless Mist.authorized?(:create_post, self)
    @post = Mist::Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    redirect_to posts_path and return unless Mist.authorized?(:update_post, self)
    @post = Mist::Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    redirect_to posts_path and return unless Mist.authorized?(:create_post, self)
    @post = Mist::Post.new(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, :notice => 'Post was successfully created.' }
        format.json { render :json => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    redirect_to posts_path and return unless Mist.authorized?(:update_post, self)
    @post = Mist::Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, :notice => 'Post was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    redirect_to posts_path and return unless Mist.authorized?(:destroy_post, self)
    @post = Mist::Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :ok }
    end
  end
  
  private
  def cache_path
    options = Mist.authorized_actions.inject(ActiveSupport::OrderedHash.new) do |hash, key|
      hash[key] = true if Mist.authorized?(key, self)
      hash
    end
  end
  
  def bump_post_popularity
    @post = Mist::Post.find(params[:id])
    redirect_to posts_path and return unless @post.published? || Mist.authorized?(:view_drafts, self)
    Mist::Post.increase_popularity(@post) if @post
  end
end
