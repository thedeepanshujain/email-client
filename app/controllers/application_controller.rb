class ApplicationController < ActionController::Base
	include SessionsHelper
	include OAuthHelper
	include GmailHelper
	include MessagesHelper
	include AssignmentsHelper
end
