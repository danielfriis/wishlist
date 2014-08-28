class Plugin::UsersController < ApplicationController

  layout 'plugin'

  include UsersHelper

  def new
    session[:return_to] = plugin_path
    @user = User.new(gender: "Female")
  end

  def create
    @user = User.new(params[:user])

    if create_user @user
      @list = @user.lists.first
      wishes = save_wishes_from_cookie

      @list.wishes << wishes
      cookies.delete :wishes

      redirect_to plugin_list_path(@list)
    else
      render 'new'
    end
  end

end
