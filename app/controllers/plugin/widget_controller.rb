class Plugin::WidgetController < ApplicationController

  def index
    render 'plugin/widget/index', layout: false
  end

end
