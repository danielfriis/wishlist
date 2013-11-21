class Admin::ItemsController < ApplicationController
	before_filter :authenticate_admin!

	def index
    @items = Item.paginate(page: params[:page]).order("created_at desc")
	end

	def show
		@item = Item.find(params[:id])
		@items = @item.vendor.present? ? @item.vendor.items.sample(9) : Item.all.sample(9)
		@commentable = @item
	  @comments = @commentable.comments
	  @comment = Comment.new
	end

	def destroy
		@item = Item.find(params[:id])
		@item.destroy
		respond_to do |format|
      format.html { redirect_to admin_index_url }
      format.js
    end 
	end


  private

    def authenticate_admin!
      unless signed_in? && current_user.admin?
      	redirect_to root_path
      end
    end
end