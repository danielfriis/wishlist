class LikesController < ApplicationController
	  before_filter :signed_in_user
	  include Analyzable

	  def create
	  	@item = Item.find(params[:like][:item_id])
	  	current_user.likes.create!(item_id: @item.id)
	  	respond_to do |format|
	      format.html { redirect_to @item }
	      format.js
	    end
	  end

	  def destroy
	  	like = Like.find(params[:id])
	  	@item = like.item
	  	like.destroy
	  	respond_to do |format|
	      format.html { redirect_to @item }
	      format.js
	    end
	  end
end
