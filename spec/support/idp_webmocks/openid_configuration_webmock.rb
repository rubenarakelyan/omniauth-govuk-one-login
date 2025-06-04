module OpenidConfigurationWebmock
  def stub_openid_configuration_request(
    body: default_openid_configuration_response,
    status: 200
  )
    stub_request(
      :get,
      IdpFixtures.openid_configuration_endpoint
    ).to_return(body: body, status: status)
  end

  def default_openid_configuration_response
    {
      authorization_endpoint: IdpFixtures.authorization_endpoint,
      jwks_uri: IdpFixtures.jwks_endpoint,
      token_endpoint: IdpFixtures.token_endpoint,
      userinfo_endpoint: IdpFixtures.userinfo_endpoint,
      end_session_endpoint: IdpFixtures.end_session_endpoint
    }.to_json
  end
end
