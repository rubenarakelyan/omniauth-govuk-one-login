module OmniAuth
  module GovukOneLogin
    class IdTokenRequest
      attr_reader :code, :session, :client

      def initialize(code:, session:, client:)
        @code = code
        @session = session
        @client = client
      end

      def request_id_token
        response = Faraday.post(
          client.idp_configuration.token_endpoint,
          client_assertion: client_assertion_jwt,
          client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
          code: code,
          code_verifier: client.pkce ? get_oidc_value_from_session(:code_verifier_value) : nil,
          grant_type: "authorization_code",
          redirect_uri: client.redirect_uri
        )
        raise_id_token_request_failed_error(response) unless response.success?
        id_token_from_response(response)
      end

      private

      def client_assertion_jwt
        now = Time.now.to_i
        payload = {
          aud: client.idp_configuration.token_endpoint,
          iss: client.client_id,
          sub: client.client_id,
          exp: now + 300, # 5 minutes
          jti: SecureRandom.urlsafe_base64(32),
          iat: now
        }
        JWT.encode(payload, client.private_key, "RS256")
      end

      def id_token_from_response(response)
        parsed_body = JSON.parse(response.body)
        IdToken.new(
          client: client,
          access_token: parsed_body["access_token"],
          id_token: parsed_body["id_token"],
          expires_in: parsed_body["expires_in"],
          token_type: parsed_body["token_type"]
        )
      end

      def raise_id_token_request_failed_error(response)
        status_code = response.status
        error_message = "ID token request failed with status code: #{status_code}"
        raise IdTokenRequestError, error_message
      end

      def get_oidc_value_from_session(key)
        oidc_session = session[:oidc].symbolize_keys
        return if oidc_session.nil?

        oidc_session[key]
      end
    end
  end
end
