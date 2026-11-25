class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [ :edit, :update ]

  def show
    if params[:id]
      @profile = visible_profiles.find(params[:id])
    else
      @profile = current_user.profile
    end

    @user = @profile.user
    @posts = @user.posts.order(created_at: :desc)
    @new_post = current_user.posts.new
    @active_friends = visible_friends.first(4)
  end
  def edit
  end

  def update
    avatar = params.dig(:profile, :avatar)

    if avatar.present?
      current_user.avatar = avatar

      unless current_user.valid?
        current_user.errors.full_messages.each do |message|
          @profile.errors.add(:base, message)
        end

        return render :edit, status: :unprocessable_entity
      end
    end

    @profile.assign_attributes(profile_params)

    if @profile.valid?
      ActiveRecord::Base.transaction do
        current_user.save! if avatar.present?
        @profile.update!(profile_params)
      end

      redirect_to profile_path,
                  notice: "Profile settings updated successfully!",
                  status: :see_other
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
