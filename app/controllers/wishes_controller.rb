class WishesController < ApplicationController
  before_filter :signed_in_user, only: [:new, :create, :update, :destroy]
  before_filter :correct_user,   only: :destroy
  include Analyzable

  def show
    @wish = Wish.find_by_id(params[:id]) || not_found
    @items = @wish.item.vendor.present? ? @wish.item.vendor.items.sample(9) : Item.all.sample(9)
    @commentable = @wish
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def new
    @item = Item.find_by_id(params[:item_id])
    @wish = Wish.new
  end

  def create
    @item = Item.find_by_id(params[:wish][:item_id])
    @wish = Wish.create!(title: @item.title, item_id: params[:wish][:item_id], list_id: params[:wish][:list_id])
    tracker.track(current_user.id, 'Added a wish')
    tracker.increment(current_user.id, {'Wishes added' => 1})
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def destroy
    @item = @wish.item
    @wish.destroy
    tracker.track(current_user.id, 'Removed a wish')
    tracker.increment(current_user.id, {'Wishes removed' => 1})
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end 
  end

  def update
    @wish = Wish.find(params[:id])
    tracker.track(current_user.id, 'Updated a wish')
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

  def sort
    @wish = Wish.find(params[:id])

    # .attributes is a useful shorthand for mass-assigning
    # values via a hash
    @wish.update_attributes(params[:wish])
    @wish.save!

    # this action will be called via ajax
    render nothing: true
  end

  private

    def correct_user
      @wish = current_user.wishes.find_by_id(params[:id])
      redirect_to current_user if @wish.nil?
    end
end