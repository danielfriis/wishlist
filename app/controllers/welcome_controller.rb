class WelcomeController < ApplicationController

	def index
	  if signed_in?
	    redirect_to current_user
	  else
	    redirect_to home_path
	  end
	end

end