module AssignmentsHelper

	def new_assignment (message_id, assigned_to, assigned_from)

		# CREATE NEW ASSIGNMENT 
		@assignment_new = Assignment.new
		@assignment_new.feed(message_id, assigned_to, assigned_from)
		if @assignment_new.save
			@assignment_new = Assignment.find_by(message_id: message_id, assigned_to: assigned_to, assigned_from: assigned_from)
		else
			raise 'Unable to assign'
		end

		# UPDATE OLD ASSIGNMENT
		unless assigned_from.nil?
			@assignment_old = Assignment.find_by(message_id: message_id, assigned_to: assigned_from)
			@assignment_old.update_unassigned
		end

		# ADD/UPDATE MESSAGE IN DB
		@message_gmail = get_message_by_id (message_id)
		
		@message_db = Message.find_by(message_id: message_id)

		if @message_db.nil?
			#CREATE NEW MESSAGE ENTRY
			@message_db = Message.new
			@message_db.first_assignment(@message_gmail, @assignment_new)
			
			if @message_db.save
				message_db = Message.find_by(assignment_id: @assignment_new.id)
			else
				raise 'Unable to create message'
			end

		else
			#UPDATE MESSAGE ENTRY
			@message_db.update_assignment(assigned_to, @assignment_new.id)
		end

		# UPDATE ASSIGNED_TO USER AND ASSIGNED_FROM USER
		@assigned_to_user = User.find_by(id: assigned_to)
		@assigned_to_user.assigned(message_id, assigned_from)

		@assigned_from_user = User.find_by(id: assigned_from)
		unless @assigned_from_user.nil?
			@assigned_from_user = User.find_by(id: assigned_from)
			@assigned_from_user.unassigned(message_id)
		end

	end
end
