require 'mail'

module MessagesHelper

	def create_mail(email_from, email_to, subject, message_text, file_path, references, reply_to)
		
		unless file_path.nil? 
			file_name = File.basename(file_path)
		end

		mail = Mail.new do
			from     email_from
			to       email_to
			subject  subject
			body     message_text
		end

		mail.add_file(:filename => file_name, :content => File.read(file_path))
		mail.references= references
		mail.in_reply_to= reply_to

		return mail
	end
end