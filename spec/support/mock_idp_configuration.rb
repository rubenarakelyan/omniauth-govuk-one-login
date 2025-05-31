class MockIdpConfiguration
  def idp_base_url
    IdpFixtures.base_url
  end

  def authorization_endpoint
    IdpFixtures.authorization_endpoint
  end

  def token_endpoint
    IdpFixtures.token_endpoint
  end

  def userinfo_endpoint
    IdpFixtures.userinfo_endpoint
  end

  def end_session_endpoint
    IdpFixtures.end_session_endpoint
  end

  def jwks_uri
    IdpFixtures.jwks_uri
  end

  def public_keys
    IdpFixtures.public_keys
  end
end
