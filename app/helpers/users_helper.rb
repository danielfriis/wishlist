module UsersHelper

  def admin?(user)
  	user.email == "daniel.friis@gmail.com"
  end
end