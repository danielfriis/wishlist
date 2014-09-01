class Plugin::SessionsController < ApplicationController

  layout 'plugin'

  def new
    session[:return_to] = plugin_path
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_to plugin_path
    else
      flash.now[:error] = 'Invalid email/password combination'
      render :new
    end
  end

  def destroy
    sign_out
    redirect_to plugin_path
  end

end
