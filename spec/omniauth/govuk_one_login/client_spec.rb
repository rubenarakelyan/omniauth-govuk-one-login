describe OmniAuth::GovukOneLogin::Client do
  it "initializes" do
    idp_configuration = MockIdpConfiguration.new
    allow(OmniAuth::GovukOneLogin::IdpConfiguration).to receive(:new).
      with(idp_base_url: IdpFixtures.base_url).
      and_return(idp_configuration)

    subject = described_class.new(
      client_id: ClientFixtures.client_id,
      idp_base_url: IdpFixtures.base_url,
      private_key: ClientFixtures.private_key,
      redirect_uri: ClientFixtures.redirect_uri,
      scope: "openid,email",
      ui_locales: "en",
      vtr: ["Cl.Cm"],
      pkce: true,
      userinfo_claims: []
    )

    expect(subject.client_id).to eq(ClientFixtures.client_id)
    expect(subject.idp_configuration).to eq(idp_configuration)
    expect(subject.private_key).to eq(ClientFixtures.private_key)
    expect(subject.redirect_uri).to eq(ClientFixtures.redirect_uri)
    expect(subject.scope).to eq("openid,email")
    expect(subject.ui_locales).to eq("en")
    expect(subject.vtr).to eq(["Cl.Cm"])
    expect(subject.pkce).to eq(true)
    expect(subject.userinfo_claims).to eq([])
  end
end
