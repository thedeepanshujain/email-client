require 'mail'

module MessagesHelper

	def add_to_db(messages_gmail, status)
		messages_db = Array.new()
		messages_gmail.each do |message_gmail|
			message_id = message_gmail.id
			message_db = Message.find_by(message_id: message_id)
			if message_db.nil?
				message_db = Message.new
				message_db.gmail_to_db(message_gmail, status)
			end

			if message_db.save
				messages_db << message_db
				"Saved to db : "+message_id.to_s
			else
				raise 'Unable to save to db. Please check.'
			end
		end

		return messages_db
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

	def update_db_reply(souce_message, sent_message)

		#CREATE SENT MESSAGE
		sent_message_db = Message.new
		sent_message_db.gmail_to_db(sent_message, 2)
		sent_message_db.reply_to = souce_message.id

		if sent_message_db.save
			puts 'Saved message to db'
		else
			raise 'Unable to save to db. Please check.'
		end


		#UPDATE SOURCE MESSAGE
		source_message_db = Message.find_by(message_id: souce_message.id)
		source_message_db.update_replied(sent_message.id, current_user.id)
		
		#UPDATE ASSIGNMENT
		source_assignment = Assignment.find_by(id: source_message_db.assignment_id)
		unless source_assignment.nil?
			source_assignment.update_replied
		end
		puts 'UPDATING USER DATA'
		puts current_user.class
		puts current_user.to_json
		gets
		#UPDATE USER_DATA
		current_user.replied_to(source_message_db.message_id)
	end

	def pending_message_params(current_user)
		return {
			:status => Message.STATUS_RECEIVED,
			:assigned_to => current_user.id,
			:reply => nil
		}
	end

	def message_to_plain_text (message_gmail)
		data_plain = ''
		if message_gmail.payload.mime_type.include? 'text'
			data_plain = message_gmail.payload.body.data
		elsif message_gmail.payload.mime_type.include? 'multipart'
			message_gmail.payload.parts.each do |part|
			case part.mime_type
				when 'text/plain'
					data_plain += part.body.data.force_encoding('UTF-8')
			end
		end
		else
			data_plain = message_gmail.snippet
		end
		return data_plain
	end



end