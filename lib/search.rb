class Search < ApplicationController

  def search
    if params[:search]
      @users = User.search(params[:search]).most_followers.paginate(page: params[:page], per_page: 10)
      @vendors = Vendor.search(params[:search]).most_followers.paginate(page: params[:page], per_page: 10)
    else
      @users = User.most_followers.paginate(page: params[:page], per_page: 10)
      @vendors = Vendor.most_followers.paginate(page: params[:page], per_page: 10)
    end
  end

end