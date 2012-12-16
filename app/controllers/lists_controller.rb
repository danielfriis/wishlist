class ListsController < ApplicationController
  before_filter :signed_in_user

  def create
    @list = current_user.lists.build(params[:list])
    if @list.save
      flash[:success] = "List created!"
      redirect_to root_url
    else
      render 'static_pages/home'
    end
  end

  def destroy
  end
end