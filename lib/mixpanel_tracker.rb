class MixpanelTracker
	require 'mixpanel-ruby'
	
  def initialize(user_id) 
    @user_id = user_id 
  end 
  
  def track(event, params = {}) 
    tracker.track(@user_id, event, params) 
  end 
  
  private 
  
  def tracker 
    @tracker ||= Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
  end 
end