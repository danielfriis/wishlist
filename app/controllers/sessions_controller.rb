class SessionsController < ApplicationController
  include Analyzable

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
    end
    # Log the authorizing user in.
    sign_in @auth.user
    tracker.alias(@auth.user.id, cookies[:mp_distinct_id]) if cookies[:mp_distinct_id] if @auth.user.new_record?
    tracker.people_set({
          '$name' => @auth.user.name,
          '$email' => @auth.user.email,
          '$gender' => @auth.user.gender
      });
    redirect_to @auth.user, notice: "Welcome, #{current_user.name}."
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end