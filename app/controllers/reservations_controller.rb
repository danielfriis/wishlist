class ReservationsController < ApplicationController
  before_filter :signed_in_user
  include Analyzable

	def create
		@wish = Wish.find(params[:reservation][:wish_id])
		current_user.reservations.create!(wish_id: @wish.id)
		respond_to do |f|
			f.html { redirect_to @wish.list }
			f.js
		end
	end

	def destroy
		@wish = Reservation.find(params[:id]).wish
		current_user.reservations.find(params[:id]).destroy
		respond_to do |format|
      format.html { redirect_to @wish }
      format.js
    end
	end

end
