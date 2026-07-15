class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @profile = current_user.profile
    @posts = current_user.posts
    @new_post = current_user.posts.new
  end
end
