class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :following, :followers]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :find_user, only: [:show, :edit, :update_password, :update_notifications, :update, :following, :followers]
  include Analyzable
  include UsersHelper

  def show
    @lists = @user.lists.allowed(current_user)
    @wishes = @user.wishes.rank(:row_order)
    @list = current_user.lists.build if signed_in?
  end

  def new
    @user = User.new(gender: "Female")
  end

  def create
    @user = User.new(params[:user])
    if create_user @user
      redirect_to @user
    else
      render 'new'
    end
  end

  def index
    if params[:search]
      @users = User.search(params[:search]).top_wishers.paginate(page: params[:page], per_page: 10)
    else
      @users = User.top_wishers.paginate(page: params[:page], per_page: 10)
    end
  end

  def edit

  end

  def update_password
    render template: 'users/edit'
  end

  def update_notifications
    render template: 'users/edit'
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to edit_user_path(@user)
    else
      @updated = params[:updated]
      render 'edit'
    end
  end

  def user_suggestion
    # handled by search_suggestion.rb middleware
    # results = User.search(params[:query]).most_followers
    # render json: results.to_json
  end

  def following
    @lists = @user.lists
    @title = "Following"
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @lists = @user.lists
    @title = "Followers"
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
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
