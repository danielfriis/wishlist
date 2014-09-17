class ApplicationController < ActionController::Base
  
  protect_from_forgery
  include SessionsHelper


  def not_found
	  raise ActionController::RoutingError.new('Not Found')
	end

  def track_activity(trackable, action = params[:action])
    current_user.activities.create! action: action, trackable: trackable
  end

  private
    def mobile_device?
      request.user_agent =~ /Mobile|webOS/
    end
    helper_method :mobile_device?
end