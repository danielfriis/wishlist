class PluginController < ApplicationController

  include UsersHelper

  def script
    plugin_dir = Rails.root + 'public/plugin'
    versions = Dir[File.join plugin_dir, '/*.js']
    latest = versions.sort().last
    send_file latest
  end

  def index
    render 'index'
  end

  def signin
    session[:return_to] = plugin_index_path
  end

  def signout
    sign_out
    redirect_to plugin_index_path
  end

  def signup
    session[:return_to] = plugin_index_path
    @user = User.new(gender: "Female")
  end

  def signup_create
    @user = User.new(params[:user])
    if create_user @user
      redirect_to plugin_index_path
    else
      render 'signup'
    end
  end

end
