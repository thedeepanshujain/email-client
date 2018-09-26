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
			unless session.has_key?(:auth_credentials)
				initialize_oauth
			end
			redirect_to current_user
		else
			flash[:danger] = "Invalid email/password combination"
			render 'new'
		end
	end

	def destroy
		logout
		redirect_to root_url
	end

	def oauth
		initialize_oauth params[:code]
		redirect_to current_user
	end
end
