class UserMailer < ApplicationMailer
  default from: "welcome@odinbook.com"

  def welcome_email(user)
    @user = user
    @display_name = user.name.presence || user.email.split("@").first

    mail(
      to: @user.email,
      subject: `✨ Welcome to OdinBook, #{@display_name}! Glad you're here.`
    )
  end
end
