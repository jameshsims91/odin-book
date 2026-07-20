class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [ :show, :edit, :update ]

  def show
    @profile = current_user.profile
    @posts = current_user.posts.select(&:persisted?)
    @new_post = current_user.posts.new
    @followers = current_user.inverse_friends.includes(:profile)
    @pending_requests = current_user.inverse_friendships.where(status: "pending").includes(:user)
  end

  def edit
  end

  def update
    if  @profile.update(profile_params)
      redirect_to authenticated_root_path, notice: "Profile settings updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = current_user.profile
  end

  def profile_params
    params.expect(profile: [ :information, :picture_url ])
  end
end
