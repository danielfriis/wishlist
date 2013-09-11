class StaticPagesController < ApplicationController
  helper_method :sort_general, :sort_gender

  def home
    redirect_to current_user if signed_in?
    @items = Item.sort(sort_general, sort_gender).page(params[:page]).per_page(9)

    # if params[:sort] == "recent"
    #   @items = Item.recent.page(params[:page]).per_page(9)
    # elsif params[:sort] == "popular"
    #   @items = Item.popular.page(params[:page]).per_page(9)
    # else
    #   @items = Item.recent.page(params[:page]).per_page(9)
    # end

  end

  def help
  end

  def about
  end

  def contact
  end

  def privacy
  end

  def terms
  end

private
  def sort_general
    %w[recent popular].include?(params[:sort]) ? params[:sort] : "recent"
  end

  def sort_gender
    %w[Male Female].include?(params[:gender]) ? params[:gender].titleize : "all"
  end
  
end


