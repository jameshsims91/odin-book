module UsersHelper
  def all_friends
    (friends.merge(Friendship.accepted) + inverse_friends.merge(Friendship_accepted)).uniq
  end
end
