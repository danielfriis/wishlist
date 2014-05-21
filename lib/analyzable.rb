module Analyzable 
  
  private 
  
  def tracker
    @tracker ||= MixpanelTracker.new(user_id)
  end
  
  def user_id
    current_user.id
  end 
end 