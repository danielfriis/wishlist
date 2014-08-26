class PluginController < ApplicationController


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

  end

  def signup
    @user = User.new(gender: "Female")
  end
end
