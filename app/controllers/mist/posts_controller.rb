class Mist::PostsController < ApplicationController
  # caches_action :feed, :show, :layout => false
  caches_action :index
  cache_sweeper Mist::PostSweeper
  
  # GET /posts
  # GET /posts.json
  def index
    if Mist.authorized? :view_drafts, self
      @posts = posts_from_cache('mist/posts/last_20_with_drafts') { Mist::Post.last(20).reverse }
    else
      @posts = posts_from_cache('mist/posts/most_recent_20_published') { Mist::Post.recently_published(20) }
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
    @post = Mist::Post.find(params[:id])
    
    @post.popularity += 1
    @post.save!

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @post = Mist::Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Mist::Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
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
    @post = Mist::Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :ok }
    end
  end
  
  private
  def posts_from_cache(key)
    return yield
    
    if ids = Rails.cache.fetch(key)
      return ids.collect { |id| Mist::Post.find id }
    else
      yield.tap do |posts|
        Rails.cache.write(key, posts.collect { |p| p.id })
      end
    end
  end
end
