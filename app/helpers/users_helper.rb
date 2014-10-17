module UsersHelper
  include Analyzable

  def admin?(user)
    user.email == "daniel.friis@gmail.com"
  end

  def create_user(user)
    if user.save
      UserMailer.delay.signup_confirmation(user.id) # When using delayed_job for actionmailer '.deliver' is omitted
      user.delay.subscribe_email

      user.lists.create!(name: "My Wish List")
      sign_in user
      flash[:success] = "Thanks for signing up!"

      tracker.alias(user.id, cookies[:mp_distinct_id].split("%22")[3]) if cookies[:mp_distinct_id]
      tracker.people_set(user.id, {
                           '$name' => user.name,
                           '$email' => user.email,
                           '$gender' => user.gender
                         });
      tracker.track(user.id, 'Signup')

      user
    else
      false
    end
  end
end
