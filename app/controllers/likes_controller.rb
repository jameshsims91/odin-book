class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    current_user.likes.create(post: @post) unless current_user.liked?(@post)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: posts_path }
    end
  end

  def destroy
    like = current_user.likes.find_by(post: @post)
    like&.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: posts_path }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
