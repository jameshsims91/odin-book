class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    @friend = User.find(params[:friend_id])
    @friendship = current_user.friendships.build(friend: @friend, status: "pending")

    if @friendship.save
      redirect_back fallback_location: posts_path, notice: "Friend request sent to #{@friend.name || @friend.email}!"
    else
      redirect_back fallback_location: posts_path, notice: "Unable to send friend request."
    end
  end

  def update
    @friendship = Friendship.find(params[:id])
    if @friendship.friend == current_user && friendship.update(status: "accepted")
      redirect_back fallback_location: authenticated_root_path, notice: "Friend request accepted!"
    else
      redirect_back fallback_location: authenticated_root_path, alert: "Action unauthorized."
    end
  end

  def destroy
    @friendship = Friendship.find(params[:id])
    if @friendship.user == current_user || @friendship.friend == current_user
      @friendship.destroy
      redirect_back fallback_location: authenticated_root_path, notice: "Connection removed."
    else
      redirect_back fallback_location: authenticated_root_path, alert: "Action unauthorized."
    end
  end
end
