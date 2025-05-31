module JwksWebmock
  def stub_jwks_request(body: default_jwks_response_body, status: 200)
    stub_request(:get, IdpFixtures.jwks_endpoint).
      to_return(body: body, status: status)
  end

  def default_jwks_response_body
    jwks_response_body(keys: IdpFixtures.public_key_jwks)
  end

  def jwks_response_body(keys:)
    { keys: keys }.to_json
  end
end
