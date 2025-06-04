module OmniAuth
  module GovukOneLogin
    class Callback
      attr_reader :session, :client, :id_token, :userinfo

      def initialize(session:, client:)
        @session = session.to_hash.symbolize_keys
        @client = client
      end

      def call(params)
        verify_state(params)
        handle_error(params) if params["error"]
        @id_token = IdTokenRequest.new(
          code: params["code"],
          session: session,
          client: client
        ).request_id_token
        id_token.verify(nonce: get_oidc_value_from_session(:nonce_digest))
        @userinfo = UserinfoRequest.new(
          id_token: id_token,
          client: client
        ).request_userinfo
      end

      private

      def verify_state(params)
        cb_state = params["state"]
        if cb_state.present?
          cb_state_digest = OpenSSL::Digest::SHA256.base64digest(cb_state)
          return if SecureCompare.secure_compare(
            cb_state_digest,
            get_oidc_value_from_session(:state_digest)
          )
        end
        raise CallbackStateMismatchError
      end

      def handle_error(params)
        error_type = case params["error"]
                     when "access_denied"
                       CallbackAccessDeniedError
                     when "invalid_request", "invalid_scope", "request_is_missing_parameters", "unsupported_response_type"
                       CallbackInvalidRequestError
                     when "server_error", "temporarily_unavailable", "unauthorized_client"
                       CallbackServiceUnavailableError
                     when "login_required"
                       CallbackLoginRequiredError
                     else
                       RuntimeError
                     end
        raise error_type, params["error_description"]
      end

      def get_oidc_value_from_session(key)
        oidc_session = session[:oidc].symbolize_keys
        return if oidc_session.nil?

        oidc_session[key]
      end
    end
  end
end
