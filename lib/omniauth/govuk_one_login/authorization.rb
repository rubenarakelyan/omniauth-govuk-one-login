module OmniAuth
  module GovukOneLogin
    class Authorization
      attr_reader :session, :client

      def initialize(session:, client:)
        @session = session
        @client = client
      end

      def redirect_url
        uri = URI.parse(client.idp_configuration.authorization_endpoint)
        uri.query = redirect_url_params.to_query
        uri.to_s
      end

      private

      def redirect_url_params
        {
          client_id: client.client_id,
          response_type: "code",
          request: encoded_jar_request,
          scope: client.scope
        }
      end

      def encoded_jar_request
        userinfo_claims = client.userinfo_claims.to_h { |claim| [claim, nil] }
        payload = {
          aud: client.idp_configuration.authorization_endpoint,
          iss: client.client_id,
          response_type: "code",
          client_id: client.client_id,
          redirect_uri: client.redirect_uri,
          scope: client.scope,
          state: state,
          nonce: nonce,
          vtr: client.vtr,
          ui_locales: client.ui_locales,
          claims: {
            userinfo: userinfo_claims
          }
        }
        if client.pkce
          payload.merge!({
            code_challenge: code_challenge,
            code_challenge_method: "S256"
          })
        end
        JWT.encode(payload, client.private_key, "RS256")
      end

      def state
        @state ||= begin
          state_value = SecureRandom.urlsafe_base64(48)
          state_digest = OpenSSL::Digest::SHA256.base64digest(state_value)
          session[:oidc] ||= {}
          session[:oidc][:state_digest] = state_digest
          state_value
        end
      end

      def nonce
        @nonce ||= begin
          nonce_value = SecureRandom.urlsafe_base64(24)
          nonce_digest = OpenSSL::Digest::SHA256.base64digest(nonce_value)
          session[:oidc] ||= {}
          session[:oidc][:nonce_digest] = nonce_digest
          nonce_value
        end
      end

      def code_verifier
        @code_verifier ||= begin
          code_verifier_value = SecureRandom.urlsafe_base64(36)
          session[:oidc] ||= {}
          session[:oidc][:code_verifier_value] = code_verifier_value
          code_verifier_value
        end
      end

      def code_challenge
        @code_challenge ||= begin
          code_challenge_digest = Base64.urlsafe_encode64(OpenSSL::Digest::SHA256.digest(code_verifier), padding: false)
          session[:oidc] ||= {}
          session[:oidc][:code_challenge_digest] = code_challenge_digest
          code_challenge_digest
        end
      end
    end
  end
end
