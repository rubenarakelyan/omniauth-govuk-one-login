describe OmniAuth::GovukOneLogin::IdpConfiguration do
  include OpenidConfigurationWebmock
  include JwksWebmock

  subject { described_class.new(idp_base_url: IdpFixtures.base_url) }

  {
    authorization_endpoint: "https://oidc.account.gov.uk/authorize",
    token_endpoint: "https://oidc.account.gov.uk/token",
    userinfo_endpoint: "https://oidc.account.gov.uk/userinfo",
    end_session_endpoint: "https://oidc.account.gov.uk/logout"
  }.each do |method, expected_result|
    describe "##{method}" do
      context "when the configuration request is successful" do
        before { stub_openid_configuration_request }

        it "returns the authorization endpoint" do
          result = subject.public_send(method)

          expect(result).to eq(expected_result)
        end
      end

      context "when the configuration request fails" do
        before do
          stub_openid_configuration_request(body: "Not found", status: 404)
        end

        it "raises an error" do
          expect { subject.public_send(method) }.to raise_error(
            OmniAuth::GovukOneLogin::OpenidDiscoveryError,
            "OpenID configuration request failed with status code: 404"
          )
        end
      end
    end
  end

  describe "#public_keys" do
    before { stub_openid_configuration_request }

    context "when the certs request is successful" do
      before { stub_jwks_request }

      it "returns the IDP public keys" do
        result = subject.public_keys

        expect(result.map(&:to_pem)).to eq(IdpFixtures.public_keys.map(&:public_to_pem))
      end
    end

    context "when the certs request fails" do
      before { stub_jwks_request(body: "Not found", status: 404) }

      it "raises an error" do
        expect { subject.public_keys }.to raise_error(
          OmniAuth::GovukOneLogin::OpenidDiscoveryError,
          "JWKS request failed with status code: 404"
        )
      end
    end
  end
end
