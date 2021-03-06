class Rack::Attack

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new 

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  # throttle('req/ip', :limit => 600, :period => 5.minutes) do |req|
  #   req.ip
  # end


  ### Blacklisting ###
	blacklist('block 62.210.152.149') do |req|
    # Requests are blocked if the return value is truthy
    '62.210.152.149' == req.ip
  end
  blacklist('block 62.210.167.213') do |req|
	  # Requests are blocked if the return value is truthy
	  '62.210.167.213' == req.ip
	end
  blacklist('block 62.210.91.168') do |req|
    # Requests are blocked if the return value is truthy
    '62.210.91.168' == req.ip
  end
  blacklist('block 62.210.142.7') do |req|
    # Requests are blocked if the return value is truthy
    '62.210.142.7' == req.ip
  end
  blacklist('block 62.210.122.209') do |req|
    # Requests are blocked if the return value is truthy
    '62.210.122.209' == req.ip
  end
  blacklist('block 62.210.78.209') do |req|
    # Requests are blocked if the return value is truthy
    '62.210.78.209' == req.ip
  end
  blacklist('block 188.143.232.111') do |req|
    # Requests are blocked if the return value is truthy
    '188.143.232.111' == req.ip
  end
  blacklist('block 37.187.89.77') do |req|
    # Requests are blocked if the return value is truthy
    '37.187.89.77' == req.ip
  end
  blacklist('block 37.59.32.148') do |req|
    # Requests are blocked if the return value is truthy
    '37.59.32.148' == req.ip
  end
  blacklist('block 37.187.144.114') do |req|
    # Requests are blocked if the return value is truthy
    '37.187.144.114' == req.ip
  end
  blacklist('block 94.23.251.211') do |req|
    # Requests are blocked if the return value is truthy
    '94.23.251.211' == req.ip
  end

	# Block logins from a bad user agent
	# Rack::Attack.blacklist('block bad UA logins') do |req|
	#   req.path == '/login' && req.post? && req.user_agent == 'BadUA'
	# end

	

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  # throttle('logins/ip', :limit => 5, :period => 20.seconds) do |req|
  #   if req.path == '/login' && req.post?
  #     req.ip
  #   end
  # end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)
  # throttle("logins/email", :limit => 5, :period => 20.seconds) do |req|
  #   if req.path == '/login' && req.post?
  #     # return the email if present, nil otherwise
  #     req.params['email'].presence
  #   end
  # end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  # self.throttled_response = lambda do |env|
  #  [ 503,  # status
  #    {},   # headers
  #    ['']] # body
  # end
end