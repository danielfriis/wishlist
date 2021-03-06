class Plugin::UsersController < ApplicationController

  layout 'plugin'

  include UsersHelper
  include PluginHelper

  def new
    session[:return_to] = plugin_path
    @user = User.new(gender: "Female")
  end

  def create
    @user = User.new(params[:user])

    if create_user @user
      @list = @user.lists.first
      save_wishes_to_list @list

      redirect_to plugin_list_path(@list)
    else
      render :new
    end
  end

end
