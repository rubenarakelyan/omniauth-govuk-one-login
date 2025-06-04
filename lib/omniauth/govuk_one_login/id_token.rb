module OmniAuth
  module GovukOneLogin
    IdToken = Struct.new(
      :client,
      :access_token,
      :id_token,
      :expires_in,
      :token_type
    ) do
      def initialize(
        client:,
        access_token:,
        id_token:,
        expires_in:,
        token_type:
      )
        self.client = client
        self.access_token = access_token
        self.id_token = id_token
        self.expires_in = expires_in
        self.token_type = token_type
      end

      def verify(nonce:)
        verify_nonce(nonce)
        verify_vector_of_trust
      end

      private

      def decoded_id_token
        @decoded_id_token ||= JWT.decode(
          id_token,
          client.idp_configuration.public_keys,
          true,
          algorithm: "ES256",
          aud: client.client_id,
          verify_aud: true,
          verify_iat: true,
          iss: client.idp_configuration.idp_base_url,
          verify_iss: true,
          leeway: 10
        ).first
      rescue JWT::ExpiredSignature
        raise IdTokenExpMismatchError
      rescue JWT::InvalidAudError
        raise IdTokenAudMismatchError
      rescue JWT::InvalidIatError
        raise IdTokenIatMismatchError
      rescue JWT::InvalidIssuerError
        raise IdTokenIssMismatchError
      end

      def verify_nonce(session_nonce_digest)
        token_nonce = decoded_id_token["nonce"]
        token_nonce_digest = OpenSSL::Digest::SHA256.base64digest(token_nonce)
        return true if SecureCompare.secure_compare(
          token_nonce_digest,
          session_nonce_digest
        )

        raise IdTokenNonceMismatchError
      end

      def verify_vector_of_trust
        token_vot = decoded_id_token["vot"]
        vot = client.vtr.first.split(".").reject { |vector| vector.start_with?("P") }.join(".") # remove any "level of confidence" vectors
        return true if SecureCompare.secure_compare(
          token_vot,
          vot
        )

        raise IdTokenVotMismatchError
      end
    end
  end
end
