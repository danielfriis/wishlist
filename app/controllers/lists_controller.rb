class ListsController < ApplicationController
  before_filter :signed_in_user, only: [:new, :create, :destroy]
  before_filter :correct_user,   only: :destroy
  before_filter :allowed_user, only: [:show]
  include Analyzable

  respond_to :html, :json

  def index
    @user = User.find_by_slug!(params[:user_id])
    @lists = @user.lists
  end

  def show
    @wishes = @list.wishes.rank(:row_order)
    @lists = @user.lists
    @message = Message.new
  end

  def new
    @list = List.new
  end

  def create
    @list = current_user.lists.build(params[:list])
    if @list.save
      flash[:success] = "List created!"
      tracker.track(current_user.id, "Created a list")
      tracker.increment(current_user.id, {'Lists created' => 1})
      redirect_to [current_user, @list]
    else
      redirect_to current_user
    end
  end
  
  def update
    @list = List.find(params[:id])
    @list.update_attributes(params[:list])
    respond_to do |format|
      format.html { redirect_to [@list.user, @list] }
      format.json { render json: @list }
     end
  end

  def destroy
    @list.destroy
    tracker.track(current_user.id, "Removed a list")
    redirect_to :back
  end

  def share
    @list = List.find(params[:list_id])
    @message = Message.new(params[:message])
    
    if @message.valid?
      UserMailer.share_list(@message, @list.id).deliver
      tracker.track(current_user.id, "Shared a list")
      tracker.increment(current_user.id, {'Lists shared' => 1})
      redirect_to([@list.user, @list], :notice => "Message was successfully sent.")
    else
      flash.now.alert = "Please fill all fields."
    end
  end


  private

    def correct_user
      @list = current_user.lists.find_by_id(params[:id])
      redirect_to current_user if @list.nil?
    end

    def allowed_user
      @user = User.find_by_slug!(params[:user_id])
      @list = @user.lists.find(params[:id])
      if @list.private?
        unless signed_in? && (@list.allowed_users.include?(current_user) || @list.user == current_user)
          redirect_to root_url
        end
      end
    end
end