class ReservationsController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user, only: [:create, :destroy]
  include Analyzable

	def create
		@wish = Wish.find(params[:reservation][:wish_id])
		current_user.reservations.create!(wish_id: @wish.id)
		tracker.track(current_user.id, "Reserved a gift")
		respond_to do |f|
			f.html { redirect_to @wish.list }
			f.js
		end
	end

	def destroy
		@wish = Reservation.find(params[:id]).wish
		current_user.reservations.find(params[:id]).destroy
		tracker.track(current_user.id, "Unreserved a gift")
		respond_to do |format|
      format.html { redirect_to @wish.list }
      format.js
    end
	end

	private

    def correct_user
      @user = Wish.find(params[:reservation][:wish_id]).list.user
      redirect_to(root_path) unless current_user.following?(@user)
    end
end
