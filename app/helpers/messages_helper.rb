require 'mail'

module MessagesHelper

	def add_to_db(messages_gmail, status)

		messages_gmail.each do |message_gmail|
			message_id = message_gmail.id
			message_db = Message.find_by(message_id: message_id)
			if message_db.nil?
				message_db = Message.new
				message_db = gmail_to_db(message, status)
			end

			if message_db.save
				"Saved to db : "+message_id.to_s
			else
				raise 'Unable to save to db. Please check.'
			end
		end

	end

	def create_mail(email_from, email_to, subject, message_text, references, reply_to, file_path = nil)
		
		mail = Mail.new 
		mail.from = email_from
		mail.to = email_to
		mail.subject = subject
		mail.body = message_text
		mail.references= references
		mail.in_reply_to= reply_to

		if !file_path.nil? && !file_path.empty?
			file_name = File.basename(file_path)
			mail.add_file(:filename => file_name, :content => File.read(file_path))
		end

		return mail
	end

end