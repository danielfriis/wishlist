class Plugin::ListsController < PluginController

  def index
    @wishes = ActiveSupport::JSON.decode cookies[:wishes] || []
    @list = List.new
  end

  def show
    @list = List.find params[:id]
  end

end
