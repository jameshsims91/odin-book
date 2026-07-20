class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_back fallback_location: authenticated_root_path, notice: "Comment added!"
    else
      redirect_back fallback_location: authenticated_root_path, alert: "Comment cannot be blank."
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])
    if @comment.user == current_user || @post.user == current_user
      @comment.destroy
      redirect_back fallback_location: authenticated_root_path, notice: "Comment removed successfully."
    else
      redirect_back fallback_location: authenticated_root_path, alert: "You are not authorized to delete this comment."
    end
  end

  private

  def comment_params
    params.expect(comment: [ :content ])
  end
end
