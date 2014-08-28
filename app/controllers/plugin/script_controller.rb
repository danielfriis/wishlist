class Plugin::ScriptController < ApplicationController

  layout 'plugin'

  def get
    plugin_dir = Rails.root + 'public/plugin'
    versions = Dir[File.join plugin_dir, '/*.js']
    latest = versions.sort().last
    send_file latest
  end

end
