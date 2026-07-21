class PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    @posts = Post.includes(:user).order(created_at: :desc)
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to authenticated_root_path, notice: "Your update was published!"
    else
      @profile = current_user.profile
      @posts = current_user.posts.reload
      @new_post = @post
      render "profiles/show", status: :unprocessable_entity
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
end
