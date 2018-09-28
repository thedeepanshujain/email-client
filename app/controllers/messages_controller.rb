class MessagesController < ApplicationController
	skip_before_action :verify_authenticity_token

	STATUS_SENT = 2

	def index		
		@messages_gmail, @next_page_token = get_messages('metadata')
		@endpoint = '/messages/page/' + @next_page_token
		add_to_db(@messages_gmail, 1)
	end

	def show
		@params = params
		@message_gmail = get_message_by_id(params[:id])
		@message_db = Message.find_by(message_id: @message_gmail.id)

		@headers = @message_gmail.payload.headers
		@headers.each do |header|
			case header.name
			when 'Subject'	then	@subject = header.value;
			when 'Date'		then	@date = header.value;
			when 'From'		then	@from = header.value
			end
		end

		@data_plain = ''
		if @message_gmail.payload.mime_type.include? 'text'
			@data_plain = @message_gmail.payload.body.data
		elsif @message_gmail.payload.mime_type.include? 'multipart'
			@message_gmail.payload.parts.each do |part|
			case part.mime_type
				when 'text/plain'
					@data_plain += part.body.data.force_encoding('UTF-8')
			end
		end
		else
			@data_plain = @message_gmail.snippet
		end

		# @data_plain = ''
		# @data_html = ''
		# @message.payload.parts.each do |part|
		# 	case part.mime_type
		# 		when 'text/plain'	then	@data_plain += part.body.data
		# 		when 'text/html'	then	@data_html += part.body.data
		# 	end
		# end
		# # render :json => @data_html
		# unless @data_html.empty?
		# 	temp_file = Tempfile.new(['','.html'], :encoding => 'ascii-8bit')
		# 	temp_file.write(@data_html)	
		# 	@path = 'file://'+temp_file.path
		# end
	end

	def create 
		source_message_gmail = params[:source_message_gmail]
		message_text = params[:message_text]
		file_path = params[:file_path]

		thread_id = source_message_gmail.thread_id
		source_message_id = source_message_gmail.id
		
		source_message_gmail.payload.headers.each do |header|
			case header.name
				when 'From' 		then source_from = header.value
				when 'To'			then source_to = header.value
				when 'Subject'		then source_subject = header.value
				when 'References'	then source_references = header.value
				when 'Message-ID'	then source_message_id_string = header.value
			end
		end

		email_from = source_to
		email_to = source_from
		subject = source_subject
		reply_to = source_message_id_string

		references = source_references.nil? ? '' : source_references+' '
		references += source_message_id_string
		
		mail = create_mail(email_from, email_to, subject, message_text, references, reply_to, file_path)
		send_mail_response = send_message(mail, thread_id)
		sent_message_gmail = get_message_by_id(send_mail_response.id)
		
		update_db_reply(source_message_gmail, sent_message_gmail)

	end

	def page
		messages_gmail, next_page_token = get_messages('metadata', params[:next_page_token])
		add_to_db(messages_gmail, 1)
		messages_html =  render_to_string(
			:partial => "message", 
			:collection => messages_gmail, 
			:as => 'item', 
			:layout => "../messages/message")
		
		render :json => {:messages => messages_html, :next_page_token => next_page_token}
	end
end
