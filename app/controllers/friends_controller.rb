class FriendsController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!
  def index
    @pagy, @friends = pagy_array(
      visible_friends,
      items: 12
    )
  end
end
