describe OmniAuth::GovukOneLogin::BackchannelLogoutUtility do
  include OpenidConfigurationWebmock
  include JwksWebmock

  let(:jwt_aud) { ClientFixtures.client_id }
  let(:jwt_exp) { Time.now.to_i + 300 }
  let(:jwt_iat) { Time.now.to_i - 60 }
  let(:jwt_iss) { IdpFixtures.base_url }
  let(:jwt_sub) { "fake-user-uid" }
  let(:jwt_events_claim) { { "http://schemas.openid.net/event/backchannel-logout" => {} } }
  let(:jwt) do
    JWT.encode(
      {
        aud: jwt_aud,
        exp: jwt_exp,
        iat: jwt_iat,
        iss: jwt_iss,
        sub: jwt_sub,
        events: jwt_events_claim
      },
      IdpFixtures.private_keys.first,
      "ES256"
    )
  end

  subject do
    described_class.new(
      client_id: ClientFixtures.client_id,
      idp_base_url: IdpFixtures.base_url
    )
  end

  before do
    stub_openid_configuration_request
    stub_jwks_request
  end

  describe "#get_sub!" do
    context "initialized with idp_base_url" do
      it "returns the sub field from the logout token" do
        expect(subject.get_sub!(logout_token: jwt)).to eq(jwt_sub)
      end
    end

    context "initialized with idp_config" do
      it "returns the sub field from the logout token" do
        idp_config = OmniAuth::GovukOneLogin::IdpConfiguration.new(idp_base_url: IdpFixtures.base_url)
        backchannel_logout_utility = OmniAuth::GovukOneLogin::BackchannelLogoutUtility.new(
          client_id: ClientFixtures.client_id,
          idp_configuration: idp_config
        )
        sub = backchannel_logout_utility.get_sub!(logout_token: jwt)

        expect(sub).to eq(jwt_sub)
      end
    end

    context "initialized with no arguments" do
      it "raises ArgumentError" do
        expect { OmniAuth::GovukOneLogin::BackchannelLogoutUtility.new }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#decoded_logout_token" do
    before { subject.send(:set_logout_token, jwt) }

    context "when all fields pass validation" do
      it "returns the decoded logout token" do
        expect(subject.send(:decoded_logout_token)).to include(
          "aud" => jwt_aud,
          "exp" => jwt_exp,
          "iat" => jwt_iat,
          "iss" => jwt_iss,
          "sub" => jwt_sub,
          "events" => jwt_events_claim
        )
      end
    end

    context "when the audience does not match the expected audience" do
      let(:jwt_aud) { "fake-123" }

      it "raises an error" do
        expect { subject.send(:decoded_logout_token) }.to raise_error(
          OmniAuth::GovukOneLogin::LogoutTokenAudMismatchError
        )
      end
    end

    context "when the token expiry time is in the past" do
      let(:jwt_exp) { Time.now.to_i - 60 }

      it "raises an error" do
        expect { subject.send(:decoded_logout_token) }.to raise_error(
          OmniAuth::GovukOneLogin::LogoutTokenExpMismatchError
        )
      end
    end

    context "when the issued at is in the future" do
      let(:jwt_iat) { Time.now.to_i + 60 }

      it "raises an error" do
        expect { subject.send(:decoded_logout_token) }.to raise_error(
          OmniAuth::GovukOneLogin::LogoutTokenIatMismatchError
        )
      end
    end

    context "when the issuer does not match the expected issuer" do
      let(:jwt_iss) { "https://oidc.example.gov.uk/" }

      it "raises an error" do
        expect { subject.send(:decoded_logout_token) }.to raise_error(
          OmniAuth::GovukOneLogin::LogoutTokenIssMismatchError
        )
      end
    end
  end

  describe "#verify_sub" do
    before { subject.send(:set_logout_token, jwt) }

    context "when the sub exists" do
      it "returns true" do
        expect(subject.send(:verify_sub)).to eq(true)
      end
    end

    context "when the sub does not exist" do
      let(:jwt_sub) { "" }

      it "raises an error" do
        expect { subject.send(:verify_sub) }.to raise_error(
          OmniAuth::GovukOneLogin::LogoutTokenSubMismatchError
        )
      end
    end
  end

  describe "#verify_events_claim" do
    before { subject.send(:set_logout_token, jwt) }

    context "when the events claim matches what is expected" do
      it "returns true" do
        expect(subject.send(:verify_events_claim)).to eq(true)
      end
    end

    context "when the events claim does not match what is expected" do
      let(:jwt_events_claim) { { "some-claim" => {} } }

      it "raises an error" do
        expect { subject.send(:verify_events_claim) }.to raise_error(
          OmniAuth::GovukOneLogin::LogoutTokenEventsClaimMismatchError
        )
      end
    end
  end
end
