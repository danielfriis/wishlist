class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  private
    def mobile_device?
      request.user_agent =~ /Mobile|webOS/
    end
    helper_method :mobile_device?
end