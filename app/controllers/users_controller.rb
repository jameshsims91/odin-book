class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where.not(id: current_user.id).includes(:profile)
    if params[:query].present?
      search_term = "%#{params[:query].downcase}%"
      @users = @users.joins(:profile).where(
        "LOWER(users.name) LIKE :search OR LOWER(users.username) LIKE :search OR LOWER(profiles.information) LIKE :search",
        search_term: search_term
      )
    end
  end

  def show
    @user = User.find(params[:id])
    redirect_to authenticated_root_path if @user == current_user
    @profile = @user.profile
    @posts = @user.posts.select(&:persisted?)
  end
end
