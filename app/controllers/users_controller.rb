class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where.not(id: current_user.id).includes(:profile, { avatar_attachment: :blob })

    if params[:query].present?
      search_term = "%#{params[:query].downcase}%"
      @users = @users.left_outer_joins(:profile).where(
        "LOWER(users.name) LIKE :search OR LOWER(users.username) LIKE :search OR LOWER(profiles.information) LIKE :search",
        search: search_term
      )
    end
  end

  def show
    @user = User.find(params[:id])
    redirect_to authenticated_root_path if @user == current_user
    @profile = @user.profile
    @posts = @user.posts.select(&:persisted?)
    @mutual_friends = current_user.mutual_friends_with(@user)
  end

  def search
    return render json: [] if params[:q].blank? || !current_user
    friend_ids = current_user.friendships.where(status: :accepted).pluck(:friend_id) +
                current_user.inverse_friendships.where(status: :accepted).pluck(:user_id)
    @friends = User.where(id: friend_ids)
                    .where("username ILIKE :q OR name ILIKE :q", q: "%#{params[:q]}%")
                    .limit(5)
    render json: @friends.map { |user| { name: user.name, username: user.username } }
  end
end
