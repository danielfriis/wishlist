module Analyzable 
  private 
  
  def tracker
    @tracker ||= MixpanelTracker.new
  end
  
  # def user_id
  #   current_user.id
  # end 
end 