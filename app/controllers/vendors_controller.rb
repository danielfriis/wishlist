class VendorsController < ApplicationController
	helper_method :sort_general, :sort_gender
	before_filter :find_vendor, only: [:show, :edit, :update, :destroy]

	def new
		Vendor.new
	end

	def create
		@vendor = Vendor.create!(params[:vendor])
	end

	def show
		@items = Item.sort(sort_general, sort_gender, current_user).where(vendor_id: @vendor).page(params[:page]).per_page(9)
	end

	private

		def sort_general
	    %w[recent popular following].include?(params[:sort]) ? params[:sort] : "recent"
	  end

	  def sort_gender
	    %w[Male Female].include?(params[:gender]) ? params[:gender].titleize : "all"
	  end

	  def find_vendor
      @vendor = Vendor.find_by_slug!(params[:id].split("/").last)
    end

end