class ListsController < ApplicationController
  before_filter :signed_in_user

  def create
    @list = current_user.lists.build(params[:list])
    if @list.save
      flash[:success] = "List created!"
      redirect_to current_user
    else
      redirect_to current_user
    end
  end

  def destroy
  end
end