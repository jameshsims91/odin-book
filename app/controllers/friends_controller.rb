class FriendsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @friends = pagy_array(current_user.friends, items: 12)
  end
end
