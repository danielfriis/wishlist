class VendorsController < ApplicationController
	helper_method :sort_general, :sort_gender
	before_filter :find_vendor, only: [:show, :edit, :update, :destroy, :edit_admins]
	before_filter :correct_user, only: [:edit, :update]

	def new
		Vendor.new
	end

	def create
		@vendor = Vendor.create!(params[:vendor])
	end

	def show
		@items = Item.sort(sort_general, sort_gender, current_user).where(vendor_id: @vendor).page(params[:page]).per_page(9)
	end

	def index
    if params[:search]
      @vendors = Vendor.search(params[:search]).most_followers.paginate(page: params[:page], per_page: 10)
    else
      @vendors = Vendor.most_followers.paginate(page: params[:page], per_page: 10)
    end
  end

  def edit
  	
  end

  def edit_admins
  	@admissions = @vendor.admissions
  end

  def update
  	if @vendor.update_attributes(params[:vendor])
  		flash[:success] = "Profile updated"
  		redirect_to edit_vendor_path(@vendor)
  	else
  		render 'edit'
  	end
  end

	private

		def sort_general
	    %w[recent popular following].include?(params[:sort]) ? params[:sort] : "recent"
	  end

	  def sort_gender
	    %w[Male Female].include?(params[:gender]) ? params[:gender].titleize : "all"
	  end

	  def find_vendor
      @vendor = Vendor.find_by_slug!(params[:id])
    end

    def correct_user
    	@user = @vendor.admissions.find_by_user_id(current_user.id)
    	redirect_to(@vendor) unless @user
    end

end