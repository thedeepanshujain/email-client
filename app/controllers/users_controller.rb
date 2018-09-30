class UsersController < ApplicationController

	def new
	end

	def create
		@user = User.new(user_params)
		
		if current_user.nil? && !@user.admin
			flash[:danger] = "Failed - Creating new user"
			
		elsif (current_user.nil? && @user.admin && User.count==0) || (!current_user.nil? && current_user.admin)
			if @user.save
				flash[:success] = "Success - Creating new user"
			else
				flash[:danger] = "Failed - Creating new user"
			end
		else
			flash[:danger] = "Failed - Creating new user"
		end
		render 'new'
	end

	def show
		@user = User.find_by(id: params['id'])
		redirect_to messages_path
	end

	private
	def user_params
		params.require(:users).permit(:name, :email, :password, :password_confirmation, :admin, :signature)
	end
end
