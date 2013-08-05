class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  before_filter :hostname

  def hostname
  	@hostname = request.host || "www.mydomain.com"
  end


end