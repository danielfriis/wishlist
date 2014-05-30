class MixpanelTracker
	require 'mixpanel-ruby'
	
  # def initialize() 
  # end 
  
  def track(user_id, event, params = {}) 
    tracker.track(user_id, event, params) 
  end

  def alias(new_id, old_id)
    tracker.alias(new_id,old_id)
  end

  def increment(user_id, params = {})
    tracker.people.increment(user_id, params)
  end

  def people_set(user_id, params = {})
    tracker.people.set(user_id, params)
  end

  private 
  
  def tracker
    @tracker = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN']) do |*message|
      ProxyConsumer.delay.transmit(*message)
    end
  end
end