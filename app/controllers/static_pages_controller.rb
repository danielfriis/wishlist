class StaticPagesController < ApplicationController

  def home
  	    @list = current_user.lists.build if signed_in?
  end

  def help
  end

  def about
  end

  def contact
  end
  
end
