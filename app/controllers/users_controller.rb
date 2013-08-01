class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :find_user, only: [:show, :edit, :update]

  def show
    @lists = @user.lists
    @wishes = @user.wishes.order("created_at DESC")
    @list = current_user.lists.build if signed_in?
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      @user.lists.create!(name: "General")
      sign_in @user
      flash[:success] = "Welcome to Wishlistt!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def correct_user
      @user = User.find_by_slug!(params[:id].split("/").last)
      redirect_to(root_path) unless current_user?(@user)
    end

    def find_user
      @user = User.find_by_slug!(params[:id].split("/").last)
    end
end