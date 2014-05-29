class Mixpaneltracking
  require 'mixpanel-ruby'

  def initialize
    @mixpanel = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN']) do |*message|
      ProxyConsumer.delay.transmit(*message)
    end
  end

  def added_wish(id)
    @mixpanel.track(id, "Added a wish")
  end
end