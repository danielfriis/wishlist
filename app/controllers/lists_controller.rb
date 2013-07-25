class ListsController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :correct_user,   only: :destroy

  def show
    @user = User.find(params[:user_id])
    @list = @user.lists.find(params[:id])
    @wishes = @list.wishes
    @lists = @user.lists
  end

  def create
    @list = current_user.lists.build(params[:list])
    if @list.save
      flash[:success] = "List created!"
      redirect_to @list
    else
      redirect_to current_user
    end
  end

  def destroy
    @list.destroy
    redirect_to current_user
  end

  private

    def correct_user
      @list = current_user.lists.find_by_id(params[:id])
      redirect_to current_user if @list.nil?
    end
end