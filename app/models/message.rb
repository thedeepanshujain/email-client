class Message < ApplicationRecord

	STATUS_RECEIVED = 1
	STATUS_SENT = 2

	def update_assignment (assigned_to, assignment_id)
		self.update_attribute('assigned_to', assigned_to)
		self.update_attribute('assignment_id', assignment_id)
	end

	def first_assignment(message_gmail, assignment)
		self.message_id = message_gmail.id

		self.labels = message_gmail.label_ids.to_json

		message_gmail.payload.headers.each do |header|
			case header.name
			when 'From'
				self.contact_email = header.value			
			when 'Subject'
				self.subject = header.value
			end
		end
		
		self.snippet = message_gmail.snippet 
		self.thread_id = message_gmail.thread_id

		message_time_ms = message_gmail.internal_date
		self.message_time = Time.at(message_time_ms).to_s(:db)

		self.status = STATUS_RECEIVED
		self.assigned_to = assignment.assigned_to
		self.assignment_id = assignment.id
	end
end