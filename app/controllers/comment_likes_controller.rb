class CommentLikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment

  def create
    current_user.comment_likes.create(comment: @comment)
    redirect_back fallback_location: authenticated_root_path
  end

  def destroy
    like = current_user.comment_likes.find_by(comment: @comment)
    like&.destroy
    redirect_back fallback_location: authenticated_root_path
  end

  private

  def set_comment
    @comment = Comment.find(params[:comment_id])
  end
end
