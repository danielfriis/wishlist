class ActivitiesController < ApplicationController

	respond_to :html, :json

	def index
		@activities = Activity.order("created_at desc").where(user_id: current_user.followed_users).paginate(page: params[:page], per_page: 50)
		@users = User.most_followers.limit(10)
		@vendors = Vendor.most_followers.limit(10)
	end

	def header_index
		@activities = Activity.order("created_at desc").where(user_id: current_user.followed_users).limit(5)
		respond_to do |format|
			format.html { render layout: false }
			format.json { render json: @activities }
		end
	end
end
