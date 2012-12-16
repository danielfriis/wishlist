class ApplicationController < ActionController::Base
	if Rails.env == "production"
		http_basic_authenticate_with :name => "frodo", :password => "thering" 
	end
  protect_from_forgery
  include SessionsHelper
end