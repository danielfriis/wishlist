class AdmissionsController < ApplicationController
	before_filter :signed_in_user
  include Analyzable

	respond_to :html, :json

	def create
		@admission = Admission.create!(params[:admission])
		if params[:admission][:accessible_type] == "List"
			@list = List.find(params[:admission][:accessible_id])
			tracker.track(mp_id, 'Invited user to private list') if mp_id
			UserMailer.delay.invited_to_private_list(current_user.id, @admission.user.id, @list.id)
		end
		respond_with do |format|
      format.html { redirect_to @admission }
      format.js
    end
	end

	def destroy
		@admission = Admission.find(params[:id])
		@admission.destroy
		respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
	end
end
