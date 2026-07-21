class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [ :edit, :update ]

  def show
    if params[:id]
      @profile = Profile.find(params[:id])
    else
      @profile = current_user.profile
    end

    @user = @profile.user
    @posts = @user.posts.order(created_at: :desc)
    @new_post = current_user.posts.new
  end

  def edit
  end

  def update
    if params[:profile][:avatar].present?
      current_user.avatar.attach(params[:profile][:avatar])
    end

    if @profile.update(profile_params)
      redirect_to profile_path(@profile), notice: "Profile settings updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = current_user.profile
  end

  def profile_params
    params.expect(profile: [ :information ])
  end
end
