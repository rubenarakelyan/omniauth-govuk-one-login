module UserinfoWebmock
  def stub_userinfo_request(body:, access_token:, status: 200)
    stub_request(
      :get,
      IdpFixtures.userinfo_endpoint
    ).with(
      headers: { Authorization: "Bearer #{access_token}" }
    ).to_return(body: body, status: status)
  end
end
