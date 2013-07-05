class StaticPagesController < ApplicationController


  def home

    if params[:sort] == "recent"
      @items = Item.recent.page(params[:page]).per_page(9)
    elsif params[:sort] == "popular"
      @items = Item.popular.page(params[:page]).per_page(9)
    else
      @items = Item.recent.page(params[:page]).per_page(9)
    end

  end

  def help
  end

  def about
  end

  def contact
  end

  
end


