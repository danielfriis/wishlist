class MailingController < ApplicationController

	def contact_support
		@message = Message.new(params[:message])
    if @message.valid?
      UserMailer.contact_support(@message).deliver
      redirect_to contact_path, notice: "Your message has been successfully sent! We'll get back to you shortly."
    else
      flash.now.alert = "Please make sure to fill out all the fields"
    end
	end

end