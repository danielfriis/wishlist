class Plugin::ListsController < ApplicationController

  layout 'plugin'

  def index
    @wishes = ActiveSupport::JSON.decode cookies[:wishes] || []
    @list = List.new
  end

end
