describe OmniAuth::GovukOneLogin::UserinfoRequest do
  include UserinfoWebmock

  let(:access_token) { "access-token-1234" }
  let(:id_token) do
    instance_double(
      OmniAuth::GovukOneLogin::IdToken,
      access_token: access_token
    )
  end
  let(:client) { MockClient.new }

  let(:uuid) { "asdf-1234-qwerty-5678" }
  let(:email) { "asdf@example.com" }
  let(:email_verified) { true }
  let(:response_body) do
    {
      sub: uuid,
      email: email,
      email_verified: email_verified,
    }.to_json
  end

  subject { described_class.new(id_token: id_token, client: client) }

  describe "#request_userinfo" do
    context "when the request is successful" do
      before do
        stub_userinfo_request(body: response_body, access_token: access_token)
      end

      it "returns userinfo" do
        userinfo = subject.request_userinfo

        expect(userinfo.uuid).to eq(uuid)
        expect(userinfo.email).to eq(email)
        expect(userinfo.email_verified).to eq(email_verified)
      end

      context "when the request fails" do
        before do
          stub_userinfo_request(
            body: "Access Denied",
            status: 403,
            access_token: access_token
          )
        end

        it "raises an error" do
          expect { subject.request_userinfo }.to raise_error(
            OmniAuth::GovukOneLogin::UserinfoRequestError,
            "Userinfo request failed with status code: 403"
          )
        end
      end
    end
  end
end
