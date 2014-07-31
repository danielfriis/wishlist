class UserMailer < ActionMailer::Base
  default from: "Wishlistt <no-reply@wishlistt.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup_confirmation.subject
  #
  def signup_confirmation(user_id, generated_password = nil)
    @user = User.find(user_id)
    @generated_password = generated_password if generated_password.present?

    mail to: @user.email, subject: "[Wishlistt] Sign Up Confirmation"
  end

  def new_follower(current_user, followed_user)
    @current_user = User.find(current_user)
    @followed_user = User.find(followed_user)

    mail to: @followed_user.email, subject: "#{@followed_user.name}, you have a new follower on Wishlistt"
  end

  def new_comment(current_user, followed_user, wish, comment)
    @current_user = User.find(current_user)
    @followed_user = User.find(followed_user)
    @wish = Wish.find(wish)
    @comment = Comment.find(comment)

    mail to: @followed_user.email, subject: "#{@current_user.name} commented on your wish"
  end

  def survey(user_id)
    @user = User.find(user_id)

    mail from: "Daniel Friis <df@wishlistt.com>", to: @user.email, subject: "Are we doing things right?"
  end

  def friendly_reminder(user_id)
    @user = User.find(user_id)

    mail from: "Daniel Friis <df@wishlistt.com>", to: @user.email, subject: "Friendly Reminder: Are we doing things right?"
  end

  def share_list(message, list_id)
    @message = message
    @list = List.find(list_id)

    mail from: "#{@list.user.name} <no-reply@wishlistt.com>", to: message.email, subject: "#{@list.user.name} via Wishlistt", reply_to: @list.user.email
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "[Wishlistt] Password reset"
  end

end
