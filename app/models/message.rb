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

		from_header = message_gmail.payload.headers.detect {|header| header.name.eql? 'From'}
		self.contact_email = from_header.value

		self.thread_id = message_gmail.thread_id

		message_time_ms = message_gmail.internal_date
		self.message_time = Time.at(message_time_ms).to_s(:db)

		self.status = STATUS_RECEIVED
		self.assigned_to = assignment.assigned_to
		self.assignment_id = assignment.id
	end
end