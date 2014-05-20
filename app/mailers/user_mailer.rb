class UserMailer < ActionMailer::Base
  default from: "Wishlistt <no-reply@wishlistt.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup_confirmation.subject
  #
  def signup_confirmation(user_id)
    @user = User.find(user_id)

    mail to: @user.email, subject: "[Wishlistt] Sign Up Confirmation"
  end

  def share_list(message, list)
    @message = message
    @list = list

    mail from: "#{list.user.name} <no-reply@wishlistt.com>", to: message.email, subject: "#{list.user.name} via Wishlistt", reply_to: list.user.email
  end

end
