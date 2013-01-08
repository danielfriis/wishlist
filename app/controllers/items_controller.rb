class ItemsController < ApplicationController
	before_filter :signed_in_user, only: [:new, :create, :destroy]
	before_filter :correct_user,   only: :destroy

	def show
		@item = Item.find(params[:id])
	end

	def new
		if signed_in?
			@item = Item.new
			@user = current_user
		else
			render 'users/new'
		end
	end

	def create
		@item = current_user.items.build(params[:item])
	    if @item.save
	      flash[:success] = "Item created!"
	      redirect_to @item
	    else
	      render 'new'
	    end
	end

	def destroy
		@item.destroy
		redirect_to :back
	end

  private

    def correct_user
      @item = current_user.items.find_by_id(params[:id])
      redirect_to root_url if @item.nil?
    end
end