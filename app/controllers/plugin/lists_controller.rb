class Plugin::ListsController < PluginController

  include PluginHelper

  def index
    @wishes = ActiveSupport::JSON.decode cookies[:wishes] || []
    @list = List.new
  end

  def show
    @list = List.find params[:id]
  end

  def update
    @list = List.find params[:id]
    wishes = save_wishes_from_cookie
    @list.wishes << wishes
    cookies.delete :wishes
    redirect_to plugin_list_path(@list)
  end

end
