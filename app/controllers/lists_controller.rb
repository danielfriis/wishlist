class ListsController < ApplicationController
  before_filter :signed_in_user, only: [:new, :create, :destroy]
  before_filter :correct_user,   only: :destroy

  respond_to :html, :json

  def index
    @user = User.find_by_slug!(params[:user_id])
    @lists = @user.lists
  end

  def show
    @user = User.find_by_slug!(params[:user_id])
    @list = @user.lists.find(params[:id])
    @wishes = @list.wishes.rank(:row_order)
    @lists = @user.lists
  end

  def new
    @list = List.new
  end

  def create
    @list = current_user.lists.build(params[:list])
    if @list.save
      flash[:success] = "List created!"
      redirect_to [current_user, @list]
    else
      redirect_to current_user
    end
  end
  
  def update
    @list = List.find(params[:id])
    @list.update_attributes(params[:list])
    respond_with @list
  end

  def destroy
    @list.destroy
    redirect_to :back
  end

  private

    def correct_user
      @list = current_user.lists.find_by_id(params[:id])
      redirect_to current_user if @list.nil?
    end
end