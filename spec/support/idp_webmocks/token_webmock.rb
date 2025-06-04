module TokenWebmock
  def stub_id_token_request(body:, code:, status: 200)
    stub_request(
      :post,
      IdpFixtures.token_endpoint
    ).with do |request|
      expect_id_token_request_to_be_valid(request, code: code)
      true
    end.to_return(body: body, status: status)
  end

  def parse_id_token_request_body(body)
    parsed_body = CGI.parse(body)
    parsed_body.each do |key, value|
      parsed_body[key] = value.first
    end
    parsed_body
  end

  def expect_id_token_request_to_be_valid(id_token_request, code:)
    parsed_body = parse_id_token_request_body(id_token_request.body)
    expect_client_assertion_to_be_valid(parsed_body["client_assertion"])
    expect(parsed_body["client_assertion_type"]).to eq(
      "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    )
    expect(parsed_body["code"]).to eq(code)
    expect(parsed_body["grant_type"]).to eq("authorization_code")
  end

  def expect_client_assertion_to_be_valid(client_assertion)
    jwt = JWT.decode(
      client_assertion,
      ClientFixtures.public_key,
      true,
      algorithm: "RS256"
    ).first
    expect(jwt["iss"]).to eq(ClientFixtures.client_id)
    expect(jwt["sub"]).to eq(ClientFixtures.client_id)
    expect(jwt["aud"]).to eq(IdpFixtures.token_endpoint)
    expect(jwt["jti"]).to_not be_empty
    expect(jwt["exp"]).to be >= Time.now.to_i + 300
  end
end
