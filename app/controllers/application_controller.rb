class ApplicationController < ActionController::Base
	include SessionsHelper
	include OAuthHelper
	include GmailHelper
	include MessagesHelper
end
