class Message < ApplicationRecord

	STATUS_RECEIVED = 1
	STATUS_SENT = 2

	def update_assignment (assigned_to, assignment_id)
		self.update_attribute('assigned_to', assigned_to)
		self.update_attribute('assignment_id', assignment_id)
	end

	def first_assignment(message_gmail, assignment)
		
		gmail_to_db(message_gmail, STATUS_RECEIVED)
		self.assigned_to = assignment.assigned_to
		self.assignment_id = assignment.id
	end

	def gmail_to_db(message_gmail, status)

		self.message_id = message_gmail.id
		self.labels = message_gmail.label_ids.to_json

		status_field = status==1 ? 'From' : 'To'

		message_gmail.payload.headers.each do |header|
			case header.name
			when status_field		then	self.contact_email = header.value
			when 'Subject'	then	self.subject = header.value

			end
		end
		
		self.snippet = message_gmail.snippet 
		self.thread_id = message_gmail.thread_id

		message_time_ms = message_gmail.internal_date
		self.message_time = Time.at(message_time_ms).to_s(:db)
		self.status = status
	end

	def update_replied(sent_message_id, current_user_id)
		self.update_attribute('reply', sent_message_id)
		self.update_attribute('replied_by', current_user_id)
	end
end