class Plugin::ListsController < ApplicationController

  include PluginHelper

  layout 'plugin'

  def index
    @wishes = get_wishes
    @list = List.new
  end

  def create
    @list = current_user.lists.build(params[:list])
    if @list.save
      save_wishes_to_list @list

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
    save_wishes_to_list @list

    redirect_to plugin_list_path(@list)
  end
end
