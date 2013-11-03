class ItemsController < ApplicationController
	before_filter :signed_in_user, only: [:new, :create, :update, :destroy, :bookmarklet]
	before_filter :correct_user,   only: :destroy
	impressionist :actions=>[:show]
	skip_before_filter :verify_authenticity_token, :only => [:create] #For the bookmarklet
	helper_method :sort_general, :sort_gender

	respond_to :html, :json

	def show
		@item = Item.find(params[:id])
		@items = @item.vendor.present? ? @item.vendor.items.sample(9) : Item.all.sample(9)
		@commentable = @item
	  @comments = @commentable.comments
	  @comment = Comment.new
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
		@user = current_user
    @list = current_user.lists.find(params[:list_id])
    if params[:item][:via] == "no_link"
    	@item = Item.create(params[:item])
    else
			@item = Item.find_or_create_by_link!(params[:item][:link]) do |c|
				c.assign_attributes(params[:item])
				c.vendor_id = Vendor.custom_find_or_create(params[:item][:link])
			end
		end
		@item.wishes.build(list_id: @list.id, note: params[:note])
		respond_to do |format|
	    if @item.save
	    	if params[:via] == "bookmarklet"
	    		format.json { render json: @item }
	    	else
		    	flash[:success] = "Item created!"
		    	flash.keep[:success]
		    	format.html { redirect_to :back }
		    	format.js { render :js => "window.location.replace('#{user_list_path(current_user, @list)}')" }
		      # redirect_to @item
		    end
	    else
	      render 'new'
	    end
	  end
	end

	def destroy
		@item.destroy
		redirect_to :back
	end

	def update
		@item = Item.find(params[:id])
    @item.update_attributes(params[:item])
    respond_with @item
	end

	def inspiration
		@items = Item.sort(sort_general, sort_gender, current_user).page(params[:page]).per_page(9)
	end

	def linkpreview
  	url = params[:url]
  	preview = LinkPreviewParser.parse(url) # returns a Hash
	  respond_to do |format|
		  format.json { render :json => preview }
	  end	
  end

  def bookmarklet
  	render layout: 'clean_layout'
  end

  private

		def sort_general
	    %w[recent popular following].include?(params[:sort]) ? params[:sort] : "following"
	  end

	  def sort_gender
	    %w[Male Female].include?(params[:gender]) ? params[:gender].titleize : "all"
	  end

    def correct_user
      @item = current_user.items.find_by_id(params[:id])
      redirect_to root_url if @item.nil?
    end
end