class StaticPagesController < ApplicationController
  helper_method :sort_general, :sort_gender

  def home
    redirect_to inspiration_path if signed_in?
    @items = Item.sort(sort_general, sort_gender, current_user).page(params[:page]).per_page(9)

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
    "https://api.instagram.com/v1/users/455299030/media/recent/?client_id=cf2d0800cf214129b55db2917be2ef03"
  end

  def contact
    @message = Message.new
  end

  def privacy
  end

  def terms
  end

  def search
    if params[:search]
      @users = User.search(params[:search]).most_followers.limit(10)
      @vendors = Vendor.search(params[:search]).most_followers.limit(10)
      @items = Item.search(params[:search]).popular.paginate(page: params[:page], per_page: 10)
    else
      @users = User.most_followers.limit(10)
      @vendors = Vendor.most_followers.limit(10)
      @items = Item.popular.paginate(page: params[:page], per_page: 10)
    end
  end

  def sitemap
    @static_paths = [inspiration_url, about_url, contact_url]
    @items = Item.popular
    @users = User.top_wishers
    respond_to do |format|
      format.xml
    end
  end

private
  def sort_general
    %w[recent popular following].include?(params[:sort]) ? params[:sort] : "popular"
  end

  def sort_gender
    %w[Male Female].include?(params[:gender]) ? params[:gender].titleize : "all"
  end
  
end


