describe OmniAuth::GovukOneLogin::Authorization do
  let(:client) { MockClient.new }
  let(:session) { {} }

  subject { described_class.new(session: session, client: client) }

  describe "#redirect_url" do
    it "returns an auth URL with an encoded JWT payload and saves the nonce and state in the session" do
      auth_uri = URI.parse(subject.redirect_url)

      expect(auth_uri.hostname).to eq("oidc.account.gov.uk")
      expect(auth_uri.path).to eq("/authorize")

      params = Rack::Utils.parse_query(auth_uri.query)

      expect(params["client_id"]).to eq("testclient")
      expect(params["response_type"]).to eq("code")
      expect(params["scope"]).to eq("openid,email")

      decoded_request = JWT.decode(params["request"], ClientFixtures.public_key, true, algorithm: "RS256").first

      expect(decoded_request).to include(
        "aud" => "https://oidc.account.gov.uk/authorize",
        "iss" => "testclient",
        "response_type" => "code",
        "client_id" => "testclient",
        "redirect_uri" => "https://omniauth.example.gov.uk/auth/govuk_one_login/callback",
        "scope" => "openid,email",
        "vtr" => ["Cl.Cm"],
        "ui_locales" => "en",
        "claims" => {
          "userinfo" => {}
        },
        "code_challenge_method" => "S256"
      )

      expect(decoded_request["nonce"]).to_not be_blank
      expect(decoded_request["nonce"].length).to eq(32)
      nonce_digest = OpenSSL::Digest::SHA256.base64digest(decoded_request["nonce"])
      expect(nonce_digest).to eq(session[:oidc][:nonce_digest])

      expect(decoded_request["state"]).to_not be_blank
      state_digest = OpenSSL::Digest::SHA256.base64digest(decoded_request["state"])
      expect(state_digest).to eq(session[:oidc][:state_digest])

      expect(decoded_request["code_challenge"]).to_not be_blank
      expect(decoded_request["code_challenge"].length).to eq(43)
      code_challenge_digest = Base64.urlsafe_encode64(OpenSSL::Digest::SHA256.digest(session[:oidc][:code_verifier_value]), padding: false)
      expect(code_challenge_digest).to eq(session[:oidc][:code_challenge_digest])
    end
  end
end
