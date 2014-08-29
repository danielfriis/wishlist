class Plugin::ListsController < ApplicationController

  include PluginHelper

  layout 'plugin'

  def index
    @wishes = ActiveSupport::JSON.decode cookies[:wishes] || []
    @list = List.new
  end

  def create
    @list = current_user.lists.build(params[:list])
    if @list.save
      wishes = save_wishes_from_cookie
      @list.wishes << wishes
      cookies.delete :wishes

      redirect_to plugin_list_path(@list)
    else
      redirect_to current_user
    end
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
