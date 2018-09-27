class Assignment < ApplicationRecord

	def feed (message_id, assigned_to, assigned_from)
		self.message_id = message_id
		self.assigned_to = assigned_to
		self.assigned_from = assigned_from
		self.assigned_time = Time.now.to_s(:db)
		self.status = 1
	end

	def update_unassigned
		self.update_attribute('status', -1)
	end
end
