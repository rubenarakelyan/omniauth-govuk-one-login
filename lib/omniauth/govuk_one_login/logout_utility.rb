module OmniAuth
  module GovukOneLogin
    # Assists in RP-initiated logout: https://docs.sign-in.service.gov.uk/integrate-with-integration-environment/managing-your-users-sessions/#log-your-user-out-of-gov-uk-one-login
    # @example RP-initiated logout in Rails controller using Devise
    #   class SessionsController < Devise::SessionsController
    #     def destroy
    #       logout_request = self.class.logout_utility.build_request(
    #         id_token_hint: session[:id_token],
    #         post_logout_redirect_uri: root_url
    #       )
    #       sign_out(current_user)
    #       redirect_to(logout_request.redirect_uri) and return
    #     end
    #
    #     # Avoid making multiple HTTP requests to determine logout URL by memoizing utility class
    #     def self.logout_utility
    #       @logout_utility ||=
    #         OmniAuth::GovukOneLogin::LogoutUtility.new(idp_base_url: Rails.configuration.oidc["idp_url"])
    #     end
    #   end
    class LogoutUtility
      attr_reader :state

      Request = Struct.new(:redirect_uri, :state)

      # Initializes with one of idp_base_url, idp_configuration or end_session_endpoint.
      # Initializing with idp_base_url and idp_configuration may send an HTTP request to
      # fetch the OpenID configuration. The object should be memoized to avoid sending an
      # HTTP request for each logout.
      def initialize(idp_base_url: nil, idp_configuration: nil, end_session_endpoint: nil)
        check_initialize_arguments!(idp_base_url, idp_configuration, end_session_endpoint)

        if end_session_endpoint
          @end_session_endpoint = end_session_endpoint
        elsif idp_configuration
          @end_session_endpoint = idp_configuration.end_session_endpoint
        else
          configuration = OmniAuth::GovukOneLogin::IdpConfiguration.new(idp_base_url: idp_base_url)
          @end_session_endpoint = configuration.end_session_endpoint
        end
      end

      def check_initialize_arguments!(idp_base_url, idp_configuration, end_session_endpoint)
        return if idp_base_url || end_session_endpoint || idp_configuration

        raise ArgumentError, "idp_base_url, end_session_endpoint or idp_configuration must not be nil"
      end

      # @param id_token_hint [String]
      # @param post_logout_redirect_uri [String]
      # @param state [String]
      # @return [Request]
      def build_request(id_token_hint:, post_logout_redirect_uri:, state: nil)
        state ||= SecureRandom.urlsafe_base64(48)

        logout_params = { id_token_hint: id_token_hint, post_logout_redirect_uri: post_logout_redirect_uri, state: state }

        Request.new(
          "#{@end_session_endpoint}?#{logout_params.to_query}",
          state
        )
      end
    end
  end
end
