class AdmissionsController < ApplicationController

	respond_to :html, :json

	def create
		@admission = Admission.create!(params[:admission])
		if params[:admission][:accessible_type] == "List"
			@list = List.find(params[:admission][:accessible_id])
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
