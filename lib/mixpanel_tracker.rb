class MixpanelTracker
	require 'mixpanel-ruby'
	
  def initialize(user_id) 
    @user_id = user_id 
  end 
  
  def track(event, params = {}) 
    tracker.track(@user_id, event, params) 
  end

  def alias(new_id, old_id)
    tracker.alias(new_id,old_id)
  end

  def increment(params = {})
    tracker.people.increment(@user_id, params)
  end

  def people_set(params = {})
    tracker.people.set(@user_id, params)
  end

  private 
  
  def tracker
    @tracker = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN']) do |*message|
      ProxyConsumer.delay.transmit(*message)
    end
  end
end