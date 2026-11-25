
class DemoSessionsController < ApplicationController
  def create
    if user_signed_in?
      return redirect_to authenticated_root_path,
                         status: :see_other
    end

    demo_user = User.find_by(
      username: "odin_demo",
      email: "odin_demo@example.invalid",
      demo_account: true
    )

    unless demo_user&.active_for_authentication? && demo_user.profile.present?
      return redirect_to new_user_session_path,
                         alert: "The live demo is temporarily unavailable.",
                         status: :see_other
    end

    reset_session

    sign_in(:user, demo_user)

    redirect_to authenticated_root_path,
                notice: "Welcome to the OdinBook live demo!",
                status: :see_other
  end
end
