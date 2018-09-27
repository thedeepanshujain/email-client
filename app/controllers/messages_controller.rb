class MessagesController < ApplicationController

	def index
		@params = params
		@messages = get_messages('metadata')
		# render :json => @messages
	end

	def show
		@params = params
		@message = get_message_by_id(params[:id])
		
		@headers = @message.payload.headers
		@headers.each do |header|
			case header.name
			when 'Subject'
				@subject = header.value
			when 'Date'
				puts 'DATE'
				@date = header.value
			when 'From'
				puts 'FROM'
				@from = header.value
			else
			end
		end

		@data = ''
		@message.payload.parts.each do |part|
			if part.mime_type.eql? 'text/html'
				puts 'data : '+@data
				puts part.to_json
				@data += part.body.data

			end
		end

		file = Tempfile.new(['','.html'], :encoding => 'ascii-8bit')
		file.write(@data)

		@path = 'file://'+file.path
		# render :json => @path
		file.delete()




	end
end
