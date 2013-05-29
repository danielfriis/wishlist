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
    @list = current_user.lists.find(params[:list_id])
		@item = Item.create!(params[:item])
		@item.wishes.build(list_id: @list.id)
		respond_to do |format|
	    if @item.save
	    	flash[:success] = "Item created!"
	    	format.html {redirect_to(@item) }
	    	format.js { render :js => "window.location.href = ('#{item_path(@item)}');" }
	      
	      # redirect_to @item
	    else
	      render 'new'
	    end
	  end
	end

	def destroy
		@item.destroy
		redirect_to :back
	end

	def linkpreview
  	url = params[:url]
  	preview = LinkPreviewParser.parse(url) # returns a Hash
	  respond_to do |format|
		  format.json { render :json => preview }
	  end	
  end

  private

    def correct_user
      @item = current_user.items.find_by_id(params[:id])
      redirect_to root_url if @item.nil?
    end
end