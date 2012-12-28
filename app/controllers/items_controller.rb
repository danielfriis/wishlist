class ItemsController < ApplicationController
	before_filter :signed_in_user, only: [:create, :destroy]

	def show
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
      redirect_back_or current_user
    else
      render 'new'
    end
	end

	def destroy
	end

end