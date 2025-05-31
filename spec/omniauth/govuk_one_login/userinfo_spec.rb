describe OmniAuth::GovukOneLogin::Userinfo do
  let(:email) { "asdf@example.com" }

  subject do
    described_class.new(
      uuid: "asdf1234",
      email: email,
      email_verified: true
    )
  end

  describe "to_h" do
    context "when the email is present" do
      it "includes the email as the name in the hash" do
        hash = subject.to_h

        expect(hash[:name]).to eq(email)
      end
    end

    context "when the email is not present" do
      let(:email) { nil }

      it "includes the uuid as the name in the hash" do
        hash = subject.to_h

        expect(hash[:name]).to eq("asdf1234")
      end
    end
  end
end
