module OmniAuth
  module GovukOneLogin
    class IdpConfiguration
      attr_reader :idp_base_url

      def initialize(idp_base_url:)
        @idp_base_url = idp_base_url
      end

      def authorization_endpoint
        openid_configuration["authorization_endpoint"]
      end

      def token_endpoint
        openid_configuration["token_endpoint"]
      end

      def userinfo_endpoint
        openid_configuration["userinfo_endpoint"]
      end

      def end_session_endpoint
        openid_configuration["end_session_endpoint"]
      end

      def public_keys
        @public_keys = begin
          keys = JSON.parse(jwks_endpoint_response.body)["keys"]
          jwks = JWT::JWK::Set.new(keys)
          jwks.filter! { |key| key[:use] == "sig" && key[:alg] == "ES256" }
          jwks.map(&:public_key)
        end
      end

      private

      def openid_configuration
        @openid_configuration ||= JSON.parse(openid_configuration_response.body)
      end

      def openid_configuration_response
        @openid_configuration_response ||= begin
          response = Faraday.get(
            URI.join(
              idp_base_url,
              ".well-known/openid-configuration"
            )
          )
          raise_openid_configuration_request_failed_error(response) unless response.success?
          response
        end
      end

      def raise_openid_configuration_request_failed_error(response)
        status_code = response.status
        error_message = "OpenID configuration request failed with status code: #{status_code}"
        raise OpenidDiscoveryError, error_message
      end

      def jwks_endpoint_response
        @jwks_endpoint_response ||= begin
          response = Faraday.get(openid_configuration["jwks_uri"])
          raise_jwks_request_failed_error(response) unless response.success?
          response
        end
      end

      def raise_jwks_request_failed_error(response)
        status_code = response.status
        error_message = "JWKS request failed with status code: #{status_code}"
        raise OpenidDiscoveryError, error_message
      end
    end
  end
end
