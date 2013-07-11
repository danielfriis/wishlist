class WishesController < ApplicationController
  before_filter :signed_in_user, only: [:new, :create, :destroy]
  before_filter :correct_user,   only: :destroy

  def new
    @item = Item.find_by_id(params[:item_id])
    @wish = Wish.new
  end

  def create
    @item = Item.find_by_id(params[:item_id])
    @wish = Wish.create!(item_id: params[:wish][:item_id], list_id: params[:list_id])
    redirect_to :back
  end

  def destroy
    @wish.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end 
  end

  def update
    @wish = Wish.find(params[:id])
    respond_to do |format|
      if @wish.update_attributes(params[:wish])
        format.html { redirect_to(@wish, :notice => 'Wish was successfully updated.') }
        format.json { respond_with_bip(@wish) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@wish) }
      end
    end
  end

  private

    def correct_user
      @wish = current_user.wishes.find_by_id(params[:id])
      redirect_to current_user if @wish.nil?
    end
end