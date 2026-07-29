class PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Gather IDs of current user and all accepted friends to populate a true social timeline
    friend_ids = current_user.friends.map(&:id)
    feed_user_ids = [ current_user.id ] + friend_ids

    # UPDATED: Pulls only posts from the user and their friends.
    # Eager loads user profiles and active storage blobs so avatar updates render instantly.
    @posts = Post.where(user_id: feed_user_ids)
                 .includes(user: [ :profile, { avatar_attachment: :blob } ])
                 .order(created_at: :desc)
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      extract_mentions(@post)
      redirect_to authenticated_root_path, notice: "Your update was published!"
    else
      @profile = current_user.profile
      @posts = current_user.posts.reload
      @new_post = @post
      render "profiles/show", status: :unprocessable_entity
    end
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def show
    @post = Post.find(params[:id])
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      respond_to do |format|
        format.html { redirect_to post_path(@post), notice: "Post updated successfully!" }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@post) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy
    redirect_to authenticated_root_path, notice: "Post deleted successfully.", status: :see_other
  end

  private

  def post_params
    params.expect(post: [ :content, :image ])
  end

  def extract_mentions(post)
    return if post.content.blank?
    usernames = post.content.scan(/@(\w+)/).flatten.uniq
    users = User.where(username: usernames)
    post.mentioned_users = users
  end
end
