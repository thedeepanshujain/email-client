class SessionsController < ApplicationController

	def new
		if session.has_key?(:user_id)
			redirect_to current_user
		end
	end

	def create
		input_email = params[:session][:email]
		input_password = params[:session][:password]

		@user = User.find_by(email: input_email)
		if @user && @user.authenticate(input_password)
			login @user
			db_response = @user.update_login_time
			puts 'db update_login_time : #{db_response.to_json}'
			initialize_oauth

		end

	end
end
