class ProxyConsumer
	require 'mixpanel-ruby'
	
  def self.transmit(*args)
    Mixpanel::Consumer.new.send(*args)
  end
end