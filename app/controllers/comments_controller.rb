class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    respond_to do  |format|
      if @comment.save
        format.turbo_stream
        format.html { redirect_to post_path(@post), notice: "Echo recorded." }
      else
        format.html { redirect_to post_path(@post), alert: "The threads collapsed." }
      end
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])
    if @comment.user == current_user || @post.user == current_user
      @comment.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to post_path(@post), notice: "Echo erased." }
      end
    else
      redirect_to post_path(@post), alert: "You lack divine authority to alter this scroll."
    end
  end

  private

  def comment_params
    params.expect(comment: [ :content ])
  end
end
