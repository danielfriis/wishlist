class MandrillWorker 
	include Sidekiq::Worker
	sidekiq_options retry: false
	
	def perform(user_id)
		@user = User.find(user_id)
		UserMailer.signup_confirmation(@user).deliver
	end

end