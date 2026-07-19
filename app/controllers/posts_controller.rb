class PostsController < ApplicationController
  before_action :authenticate_user!

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

  private

  def post_params
    params.expect(post: [ :content ])
  end
end
