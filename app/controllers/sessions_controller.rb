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
			if !session.has_key?(:auth_credentials)
				initialize_oauth
			end

			if true
				redirect_to current_user
			end
			
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
		if params.has_key? (:error)
			render :json => error.to_json
			return
		end
		initialize_oauth params[:code]
		redirect_to current_user
	end
end
