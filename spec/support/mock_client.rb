class MockClient
  attr_reader :client_id, :idp_configuration, :private_key,
              :redirect_uri, :scope, :ui_locales, :vtr,
              :userinfo_claims

  def initialize(overrides = {})
    @client_id = ClientFixtures.client_id
    @idp_configuration = MockIdpConfiguration.new
    @private_key = ClientFixtures.private_key
    @redirect_uri = ClientFixtures.redirect_uri
    @scope = "openid,email"
    @ui_locales = "en"
    @vtr = ["Cl.Cm"]
    @userinfo_claims = []

    overrides.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def mock_method(method_name, return_value)
    instance_variable_set("@#{method_name}", return_value)
  end
end
