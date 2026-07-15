class Users:: OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :wordpress

  def wordpress
    handle_auth("Gravatar")
  end

  def github
    handle_auth("GitHub")
  end

  def failure
    redirect_to root_path, alert: "Authentication failed. Please try again."
  end

  private

  def handle_auth(kind)
    @user = User.from_omniauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: kind
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.omniauth_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
end
