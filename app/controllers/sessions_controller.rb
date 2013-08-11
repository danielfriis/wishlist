class SessionsController < ApplicationController

  def new
    render layout: 'clean_layout'
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def create_with_oauth
    auth = request.env['omniauth.auth']
    @auth = Authorization.find_with_omniauth(auth)
    if @auth.nil?
     # Create a new user or add an auth to existing user, depending on
     # whether there is already a user signed in.
      @auth = Authorization.create_with_omniauth(auth, current_user)
      sign_in @auth.user
      redirect_to root_url, signup: "success", notice: "Welcome, #{current_user.name}."
    end
    # Log the authorizing user in.
    sign_in @auth.user
    redirect_to root_url, notice: "Welcome, #{current_user.name}."
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end