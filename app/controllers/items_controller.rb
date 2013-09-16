class ItemsController < ApplicationController
	before_filter :signed_in_user, only: [:new, :create, :destroy, :bookmarklet]
	before_filter :correct_user,   only: :destroy
	impressionist :actions=>[:show]
	skip_before_filter :verify_authenticity_token, :only => [:create] #For the bookmarklet
	helper_method :sort_general, :sort_gender

	def show
		@item = Item.find(params[:id])
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
    @list = current_user.lists.find(params[:list_id])
		@item = Item.create!(params[:item])
		@item.wishes.build(list_id: @list.id)
		respond_to do |format|
	    if @item.save
	    	if params[:via] == "bookmarklet"
	    		format.json { render json: @item }
	    	else
		    	flash[:success] = "Item created!"
		    	format.html { redirect_to :back }
		    	format.json { render :js => "window.location.href = ('#{user_list_path(current_user, @list)}');" }
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

	def inspiration
		@items = Item.sort(sort_general, sort_gender).page(params[:page]).per_page(9)
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
	    %w[recent popular].include?(params[:sort]) ? params[:sort] : "recent"
	  end

	  def sort_gender
	    %w[Male Female].include?(params[:gender]) ? params[:gender].titleize : "all"
	  end

    def correct_user
      @item = current_user.items.find_by_id(params[:id])
      redirect_to root_url if @item.nil?
    end
end