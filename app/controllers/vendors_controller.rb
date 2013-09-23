class VendorsController < ApplicationController

	def new
		Vendor.new
	end

	def create
		@vendor = Vendor.create!(params[:vendor])
	end

end