module OmniAuth
  module Strategies
    class GovukOneLogin
      include OmniAuth::Strategy

      option :client_id
      option :idp_base_url, "https://oidc.account.gov.uk"
      option :private_key
      option :redirect_uri
      option :scope, "openid,email"
      option :ui_locales, "en"
      option :vtr, ["Cl.Cm"]
      option :userinfo_claims, []

      attr_reader :authorization, :callback

      uid { callback.userinfo.uuid }

      credentials do
        {
          access_token: callback.id_token.access_token,
          expires_in: callback.id_token.expires_in,
          id_token: callback.id_token.id_token,
          token_type: callback.id_token.token_type
        }
      end

      info { callback.userinfo.to_h }

      def request_phase
        @authorization = OmniAuth::GovukOneLogin::Authorization.new(
          client: client,
          session: session
        )
        redirect authorization.redirect_url
      end

      def callback_phase
        @callback = OmniAuth::GovukOneLogin::Callback.new(
          session: session,
          client: client
        )
        callback.call(request.params)
        super
      rescue OmniAuth::GovukOneLogin::Error => error
        fail!(error.key, error)
      end

      def client
        @client ||= OmniAuth::GovukOneLogin::Client.new(
          client_id: options.client_id,
          idp_base_url: options.idp_base_url,
          private_key: options.private_key,
          redirect_uri: options.redirect_uri,
          scope: options.scope,
          ui_locales: options.ui_locales,
          vtr: options.vtr,
          userinfo_claims: options.userinfo_claims
        )
      end
    end
  end
end
