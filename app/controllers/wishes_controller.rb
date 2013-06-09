class WishesController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :correct_user,   only: :destroy

  def new
    @item = Item.find_by_id(params[:item_id])
    @wish = Wish.new
  end

  def create
    @item = Item.find_by_id(params[:item_id])
    @wish = Wish.create!(item_id: params[:wish][:item_id], list_id: params[:list_id])
    redirect_to root_url
  end

  def destroy
    @wish.destroy
    redirect_to :back
  end

  private

    def correct_user
      @wish = current_user.wishes.find_by_id(params[:id])
      redirect_to current_user if @wish.nil?
    end
end