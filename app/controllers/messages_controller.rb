class MessagesController < ApplicationController
	skip_before_action :verify_authenticity_token

	STATUS_RECEIVED = 1
	STATUS_SENT = 2

	def index		
		if current_user.admin
			#SHOW ALL MESSAGES OR HISTORY
			@endpoint = '/messages/page/inbox/'
		else
			#SHOW PENDING MESSAGES BY DEFAULT
			@endpoint = '/messages/page/pending/'
		end	
	end

	def show
		@params = params
		@message_gmail = get_message_by_id(params[:id])
		@message_db = Message.find_by(message_id: @message_gmail.id)
		@all_users = User.all.take(User.count)

		@headers = @message_gmail.payload.headers
		@headers.each do |header|
			case header.name
			when 'Subject'	then	@subject = header.value;
			when 'Date'		then	@date = header.value;
			when 'From'		then	@from = header.value
			end
		end
		@data_plain = message_to_plain_text(@message_gmail)
		
		unless @message_db.reply.nil?
			@reply_gmail = get_message_by_id(@message_db.reply)
			@data_plain_reply = message_to_plain_text (@reply_gmail)
		end
		
		unless @message_db.replied_by.nil?
			@reply_user = User.find_by(id: @message_db.replied_by)
		end
		

		unless @message_db.assigned_to.nil?
			@assigned_user = User.find_by(id:  @message_db.assigned_to)
		end
		@value = [{:message_id => @message_db.message_id}, {:assigned_from => @message_db.assigned_to}]
	end

	def create 
		source_message_id = params[:source_message_id]
		message_text = params[:message_text]
		file_path = params[:file_path]

		unless current_user.signature.nil?
			message_text += '\n\n' + current_user.signature
		end

		source_message_gmail = get_message_by_id(source_message_id, 'metadata')
		thread_id = source_message_gmail.thread_id
		source_message_id = source_message_gmail.id
		source_to = nil
		source_from = nil
		source_subject = nil
		source_references = nil
		source_message_id_string = nil
		source_message_gmail.payload.headers.each do |header|
			case header.name
				when 'From'			then source_from = header.value
				when 'To'			then source_to = header.value
				when 'Subject'		then source_subject = header.value
				when 'References'	then source_references = header.value
				when 'Message-Id'	then source_message_id_string = header.value
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
		redirect_to message_path(id: source_message_id)

	end

	def page
		page_type = params[:page_type]
		page_token = params[:page_token] || 1
		page_token = page_token.to_i
		next_page_token = nil
		messages_db = nil
		case page_type
			when 'pending'
				messages_db = Message.where(message_id: current_user.get_pending_messages).order(:message_time => :desc).page(page_token).per(10)
				next_page_token = page_token + 1
			when 'replied'
				messages_db = Message.where(message_id: current_user.get_replied_messages).order(:message_time => :desc).page(page_token).per(10)
				next_page_token = page_token + 1
			when 'inbox'
				if current_user.admin
					messages_gmail, next_page_token = get_messages('metadata', page_token)
					messages_db = add_to_db(messages_gmail, 1)
				end
			when 'unassigned'
				if current_user.admin
					messages_db = Message.where(status: STATUS_RECEIVED, reply: nil, assigned_to: nil).order(:message_time => :desc).page(page_token).per(10)
					next_page_token = page_token + 1
				end
			when 'all_replied'
				if current_user.admin
					messages_db = Message.where(status: STATUS_RECEIVED).where.not(reply: nil).order(:message_time => :desc).page(page_token).per(10)
					next_page_token = page_token + 1
				end
			when 'all_pending'
				if current_user.admin
					messages_db = Message.where(status: STATUS_RECEIVED, reply: nil).where.not(assigned_to: nil).order(:message_time => :desc).page(page_token).per(10)
					next_page_token = page_token + 1
				end
		end
		messages_html =  render_to_string(:partial => "message",:collection => messages_db)
		render :json => {:messages => messages_html, :next_page_token => next_page_token, :size => messages_db.length}
	end
end