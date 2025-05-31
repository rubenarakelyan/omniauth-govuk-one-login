module IdpFixtures
  def self.private_keys
    @private_keys ||= [OpenSSL::PKey::EC.generate("prime256v1"), OpenSSL::PKey::EC.generate("prime256v1")]
  end

  def self.public_keys
    # `OpenSSL::PKey::EC` is different to other key types - we can use the root object
    private_keys
  end

  def self.public_key_jwks
    public_keys.map do |public_key|
      JWT::JWK.new(public_key, { use: "sig", alg: "ES256" }).export
    end
  end

  def self.base_url
    "https://oidc.account.gov.uk/"
  end

  def self.openid_configuration_endpoint
    "https://oidc.account.gov.uk/.well-known/openid-configuration"
  end

  def self.jwks_endpoint
    "https://oidc.account.gov.uk/.well-known/jwks.json"
  end

  def self.authorization_endpoint
    "https://oidc.account.gov.uk/authorize"
  end

  def self.token_endpoint
    "https://oidc.account.gov.uk/token"
  end

  def self.userinfo_endpoint
    "https://oidc.account.gov.uk/userinfo"
  end

  def self.end_session_endpoint
    "https://oidc.account.gov.uk/logout"
  end
end
