class UserMailer < ActionMailer::Base
  default from: "Halusta <no-reply@halusta.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup_confirmation.subject
  #
  def signup_confirmation(user_id, generated_password = nil)
    @user = User.find(user_id)
    @generated_password = generated_password if generated_password.present?

    mail to: @user.email, subject: "[Halusta] Sign Up Confirmation"
  end

  def new_follower(current_user, followed_user)
    @current_user = User.find(current_user)
    @followed_user = User.find(followed_user)

    mail to: @followed_user.email, subject: "#{@followed_user.name}, you have a new follower on Halusta"
  end

  def new_comment(current_user, followed_user, wish, comment)
    @current_user = User.find(current_user)
    @followed_user = User.find(followed_user)
    @wish = Wish.find(wish)
    @comment = Comment.find(comment)

    mail to: @followed_user.email, subject: "#{@current_user.name} commented on your wish"
  end

  def invited_to_private_list(current_user_id, invited_user_id, list_id)
    @current_user = User.find(current_user_id)
    @invited_user = User.find(invited_user_id)
    @list = List.find(list_id)

    mail to: @invited_user.email, subject: "#{@current_user.name} just invited you to see #{@current_user.gender == 'Male' ? 'his' : 'her'} private list"
  end

  def survey(user_id)
    @user = User.find(user_id)

    mail from: "Daniel Friis <df@halusta.com>", to: @user.email, subject: "Are we doing things right?"
  end

  def friendly_reminder(user_id)
    @user = User.find(user_id)

    mail from: "Daniel Friis <df@halusta.com>", to: @user.email, subject: "Friendly Reminder: Are we doing things right?"
  end

  def share_list(message, list_id)
    @message = message
    @list = List.find(list_id)

    mail from: "#{@list.user.name} <no-reply@halusta.com>", to: message.email, subject: "#{@list.user.name} via Halusta", reply_to: @list.user.email
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "[Halusta] Password reset"
  end

  def contact_support(message)
    @message = message

    mail from: "#{@message.name} <#{@message.email}>", to: 'friis+rr1edy6amqvrxwyp8drc@boards.trello.com', subject: "#{@message.subject} ##{@message.casetype}"

  end

end
