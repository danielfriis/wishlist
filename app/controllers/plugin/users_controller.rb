class Plugin::UsersController < PluginController

  include UsersHelper

  def new
    session[:return_to] = plugin_path
    @user = User.new(gender: "Female")
  end

  def create
    @user = User.new(params[:user])
    if create_user @user
      redirect_to plugin_path
    else
      render 'new'
    end
  end

end
