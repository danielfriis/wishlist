class Plugin::PluginController < ApplicationController

  layout 'plugin'

  def script
    plugin_dir = Rails.root + 'public/plugin'
    versions = Dir[File.join plugin_dir, '/*.js']
    latest = versions.sort().last
    send_file latest
  end

end
