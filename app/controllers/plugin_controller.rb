class PluginController < ApplicationController

  def script
    plugin_dir = Rails.root + 'public/plugin'
    versions = Dir[File.join plugin_dir, '/*.js']
    latest = versions.sort().last
    send_file latest
  end

  def list
    render 'index'
  end
end
