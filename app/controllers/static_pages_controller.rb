class StaticPagesController < ApplicationController

  def home
  	@items = Item.order("created_at desc").page(params[:page]).per_page(12)
  end

  def help
  end

  def about
  end

  def contact
  end
  
end
