require 'google/apis/gmail_v1'
require 'google/api_client/client_secrets'
require 'json'

module GmailHelper

	APP_NAME = 'email-management-system'
	USER_ID = 'me'
	LABEL_INBOX = 'INBOX'

	def authorize
		return initialize_oauth
	end

	def initialize_service
		@service = Google::Apis::GmailV1::GmailService.new
    	@service.client_options.application_name = APP_NAME
    	@service.authorization = authorize
    	while authorize.nil? 
    		@service.authorization = authorize
    	end
	end

	def get_messages (format = 'full', page_token = nil, max_results = 10, label_ids = LABEL_INBOX)
		@service || self.initialize_service
		result = Array.new()
		message_ids = get_message_ids(page_token, max_results, label_ids)
		message_ids.messages.each do |message|
			result << get_message_by_id(message.id, format)
		end
		return result
	end

	def get_message_ids (page_token = nil, max_results = 10, label_ids = LABEL_INBOX)
		@service || self.initialize_service
		return @service.list_user_messages(USER_ID, max_results: max_results, page_token: page_token, label_ids: label_ids)
	end

	def get_message_by_id (message_id, format='full')
		@service || self.initialize_service
		return @service.get_user_message(USER_ID, message_id, format: format)
	end

	def get_all_labels
		@service || self.initialize_service
		return @service.list_user_labels(USER_ID)
	end

	def create_label (label_object)
		@service || self.initialize_service
		return @service.create_user_label(USER_ID, label_object)
	end

	def send_message (message_body)
		@service || self.initialize_service
		return @service.send_user_message(USER_ID, message_body)
	end

	def get_user_history (start_history_id: nil, history_types: nil)
		@service || self.initialize_service
		return list_user_histories(USER_ID, start_history_id: start_history_id, history_types: history_types)

	end

end