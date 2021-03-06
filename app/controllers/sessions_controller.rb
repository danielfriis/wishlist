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
    else
      @auth.renew_token(auth)
    end

    # Log the authorizing user in.
    @auth.user.update_fb_friends
    sign_in @auth.user
    if @auth.user.new_record? && cookies[:mp_distinct_id]
      tracker.alias(@auth.user.id, JSON.parse(cookies[:mp_distinct_id])["distinct_id"])
      tracker.people_set(@auth.user.id, {
            '$name' => @auth.user.name,
            '$email' => @auth.user.email,
            '$gender' => @auth.user.gender
        });
      tracker.track(@auth.user.id, 'Signup')
    end
    redirect_back_or @auth.user
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
