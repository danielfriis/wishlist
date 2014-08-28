class Plugin::ListsController < PluginController

  def index
    @wishes = ActiveSupport::JSON.decode cookies[:wishes] || []
    @list = List.new
  end

end
