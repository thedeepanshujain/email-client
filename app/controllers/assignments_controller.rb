class AssignmentsController < ApplicationController

	def create

		assignment_input = JSON.parse(params[:user_assigned])

		message_id = nil
		assigned_to = nil
		assigned_from = nil
		assignment_input.each do |param|
			puts param
			message_id = param['message_id'] unless param['message_id'].nil?
			assigned_to = param['assigned_to'] unless param['assigned_to'].nil?
			assigned_from = param['assigned_from'] unless param['assigned_from'].nil?
		end
		new_assignment(message_id, assigned_to, assigned_from)
		redirect_to message_path(id: message_id)
	end

end
