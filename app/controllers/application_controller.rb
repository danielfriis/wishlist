class ApplicationController < ActionController::Base
	if Rails.env == "production"
		http_basic_authenticate_with :name => "frodo", :password => "thering" 
	end
  protect_from_forgery
  include SessionsHelper

  after_filter :set_access_control_headers

	def set_access_control_headers
		headers['Access-Control-Allow-Origin'] = '*'
		headers['Access-Control-Request-Method'] = '*'
	end
end