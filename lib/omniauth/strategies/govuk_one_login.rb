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
      option :pkce, false
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
          session: session,
          client: client
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
      rescue OmniAuth::GovukOneLogin::Error => e
        fail!(e.key, e)
      end

      def client
        redirect_uri = URI.parse(options.redirect_uri)

        if redirect_uri.relative?
          omniauth_origin = env["rack.session"]["omniauth.origin"] || env["omniauth.origin"]
          redirect_uri = URI.parse(omniauth_origin).merge(redirect_uri)
        end

        @client ||= OmniAuth::GovukOneLogin::Client.new(
          client_id: options.client_id,
          idp_base_url: options.idp_base_url,
          private_key: options.private_key,
          redirect_uri: redirect_uri,
          scope: options.scope,
          ui_locales: options.ui_locales,
          vtr: options.vtr,
          pkce: options.pkce,
          userinfo_claims: options.userinfo_claims
        )
      end
    end
  end
end
