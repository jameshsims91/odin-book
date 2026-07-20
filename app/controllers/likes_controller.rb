class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    current_user.likes.create(post: @post)
    redirect_back fallback_location: posts_path
  end

  def destroy
    like = current_user.likes.find_by(post: @post)
    like&.destroy
    redirect_back fallback_location: posts_path
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
