require 'google/api_client/client_secrets'
require 'json'

module OAuthHelper

	SECRETS_PATH = 'config/client_secrets.json'
	SCOPE = 'https://mail.google.com/'

	def initialize_oauth (code = nil)
		client_secrets = Google::APIClient::ClientSecrets.load(SECRETS_PATH)
		puts 'client_secrets : '+client_secrets.inspect.to_json
		auth_client = client_secrets.to_authorization
		auth_client.update!(
			:scope => SCOPE,
			:additional_parameters => {
				"access_type" => "offline",			# offline access
				"include_granted_scopes" => "true"  # incremental auth
			})

		auth_db = AuthToken.last || AuthToken.new
			
		if code.nil? && auth_db.refresh_token.nil?
			auth_uri = auth_client.authorization_uri.to_s
			redirect_to(auth_uri)
		else
			auth_client.refresh_token = auth_db.refresh_token
			auth_client.access_token = auth_db.access_token
			auth_client.expires_at = auth_db.expires_at

			auth_client.code = code

			if auth_client.expired?
				auth_client.fetch_access_token!
			end
			auth_client.client_secret = nil
			session[:auth_credentials] = auth_client.to_json
		end

		auth_db.access_token = auth_client.access_token
		auth_db.expires_at = auth_client.expires_at

		if !auth_db.refresh_token.nil?
			auth_db.refresh_token = auth_client.refresh_token
		end

		if auth_db.save
			puts 'saved auth_credentials in db'
		else
			puts 'error storing auth_credentials in db'
		end

		return auth_client
	end
end