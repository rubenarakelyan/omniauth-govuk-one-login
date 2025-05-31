describe OmniAuth::GovukOneLogin::LogoutUtility do
  include OpenidConfigurationWebmock
  let(:post_logout_redirect_uri) { "http://localhost:30001" }
  let(:state) { "0123456789098765432101" }
  let(:client_id) { "abc123" }

  subject do
    described_class.new(
      idp_base_url: IdpFixtures.base_url
    )
  end

  describe "#build_request" do
    context "initialized with idp_base_url" do
      before { stub_openid_configuration_request }
      it "generates state if not given" do
        request = subject.build_request(client_id: client_id, post_logout_redirect_uri: post_logout_redirect_uri)
        state = request.state

        expect(state).to_not be_nil
        expect(state.length).to be >= 22
      end

      it "generates redirect_uri" do
        request = subject.build_request(
          client_id: client_id,
          post_logout_redirect_uri: post_logout_redirect_uri,
          state: state
        )
        redirect_uri = request.redirect_uri

        expect(redirect_uri).to start_with(IdpFixtures.base_url)
        expect(redirect_uri).to include(client_id)
        expect(redirect_uri).to include(CGI.escape(post_logout_redirect_uri))
        expect(redirect_uri).to include(state)
      end
    end

    context "initialized with end_session_endpoint" do
      it "generates redirect_uri and does not make HTTP request for logout URL" do
        logout_utility = OmniAuth::GovukOneLogin::LogoutUtility.new(end_session_endpoint: "http://localhost:4000/logout")
        request = logout_utility.build_request(
          client_id: client_id,
          post_logout_redirect_uri: post_logout_redirect_uri,
          state: state
        )
        redirect_uri = request.redirect_uri

        expect(redirect_uri).to start_with("http://localhost:4000/logout")
        expect(redirect_uri).to include(client_id)
        expect(redirect_uri).to include(CGI.escape(post_logout_redirect_uri))
        expect(redirect_uri).to include(state)
      end
    end

    context "initialized with idp_config" do
      before { stub_openid_configuration_request }
      it "generates redirect_uri" do
        idp_config = OmniAuth::GovukOneLogin::IdpConfiguration.new(idp_base_url: IdpFixtures.base_url)
        logout_utility = OmniAuth::GovukOneLogin::LogoutUtility.new(idp_configuration: idp_config)
        request = logout_utility.build_request(
          client_id: client_id,
          post_logout_redirect_uri: post_logout_redirect_uri,
          state: state
        )
        redirect_uri = request.redirect_uri

        expect(redirect_uri).to start_with(IdpFixtures.base_url)
        expect(redirect_uri).to include(client_id)
        expect(redirect_uri).to include(CGI.escape(post_logout_redirect_uri))
        expect(redirect_uri).to include(state)
      end
    end

    context "initialized with no arguments" do
      it "raises ArgumentError" do
        expect { OmniAuth::GovukOneLogin::LogoutUtility.new }.to raise_error(ArgumentError)
      end
    end
  end
end
