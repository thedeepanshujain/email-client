class MessagesController < ApplicationController
	 skip_before_action :verify_authenticity_token

	def index		
		@messages_gmail, @next_page_token = get_messages('metadata')
		@endpoint = '/messages/page/' + @next_page_token
		add_to_db(@messages_gmail)
	end

	def show
		@params = params
		@message = get_message_by_id(params[:id])
		

		@headers = @message.payload.headers
		@headers.each do |header|
			case header.name
			when 'Subject'	then	@subject = header.value;
			when 'Date'		then	@date = header.value;
			when 'From'		then	@from = header.value
			end
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

		email_from = 'thedeepanshujain@gmail.com'
		email_to = 'Deepanshu Jain <jaindeepanshu7@gmail.com>'
		subject = 'Test Subject'
		message_text = '<h1>testing the reply feature subject test</h1>'
		file_path = nil
		references = '<CAJ=K8xt=wdTaWxU-BeeDST6u01ekYXBPPkBMG28816_f2T53yQ@mail.gmail.com> <CABBpyuTpAJHSV+42_e7ffBs4DkZQUSYT0yncUV2i7TwCUTBBVw@mail.gmail.com> <CABBpyuSPcC2C3xbNrTdYK=n+xfqk_zCEhRo7Lp-S86AC=JrgNQ@mail.gmail.com>'
		reply_to = '<CABBpyuSPcC2C3xbNrTdYK=n+xfqk_zCEhRo7Lp-S86AC=JrgNQ@mail.gmail.com>'
		thread_id = '1661cda5f0daee56'
		# email_from = params[:email_from] 
		# email_to = params[:email_to] 
		# subject = params[:subject]
		# message_text = params[:message_text]
		# file_path = params[:file_path].empty? ? nil :  params[:file_path]
		# references = params[:references]
		# reply_to = params[:reply_to]

		# mail = Base64.urlsafe_encode64(mail.to_s)

		mail = create_mail(email_from, email_to, subject, message_text, references, reply_to, file_path)
		render :json => send_message(mail, thread_id)

		{
			"id": "1661da85e4c98b59",
			"labelIds": [
				"SENT"
			],
    		"threadId": "1661cda5f0daee56"
		}

	end

	def page
		messages_gmail, next_page_token = get_messages('metadata', params[:next_page_token])
		messages_html =  render_to_string(
			:partial => "message", 
			:collection => messages_gmail, 
			:as => 'item', 
			:layout => "../messages/message")
		
		render :json => {:messages => messages_html, :next_page_token => next_page_token}
	end
end
