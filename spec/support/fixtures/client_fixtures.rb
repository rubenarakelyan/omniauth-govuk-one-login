require "openssl"

module ClientFixtures
  def self.client_id
    "testclient"
  end

  def self.private_key
    @private_key ||= OpenSSL::PKey::RSA.new(2048)
  end

  def self.public_key
    @public_key ||= private_key.public_key
  end

  def self.redirect_uri
    "https://omniauth.example.gov.uk/auth/govuk_one_login/callback"
  end
end
