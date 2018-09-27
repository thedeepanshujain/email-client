class AssignmentsController < ApplicationController

	def create
		message_id = params[:message_id]
		assigned_to = params[:assigned_to]
		assigned_from = params[:assigned_from]

		new_assignment(message_id, assigned_to, assigned_from)
	end

end
