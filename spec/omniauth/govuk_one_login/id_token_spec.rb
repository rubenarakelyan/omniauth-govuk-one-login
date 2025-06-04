describe OmniAuth::GovukOneLogin::IdToken do
  let(:session_nonce) { "123abc" }
  let(:session_nonce_digest) do
    OpenSSL::Digest::SHA256.base64digest(session_nonce)
  end

  let(:jwt_aud) { ClientFixtures.client_id }
  let(:jwt_exp) { Time.now.to_i + 300 }
  let(:jwt_iat) { Time.now.to_i - 60 }
  let(:jwt_iss) { IdpFixtures.base_url }
  let(:jwt_nonce) { session_nonce }
  let(:jwt_vot) { "Cl.Cm" }
  let(:jwt) do
    JWT.encode(
      {
        aud: jwt_aud,
        exp: jwt_exp,
        iat: jwt_iat,
        iss: jwt_iss,
        nonce: jwt_nonce,
        vot: jwt_vot
      },
      IdpFixtures.private_keys.first,
      "ES256"
    )
  end

  subject do
    OmniAuth::GovukOneLogin::IdToken.new(
      client: MockClient.new,
      access_token: "super-sekret-token",
      id_token: jwt,
      expires_in: 900,
      token_type: "Bearer"
    )
  end

  describe "#verify_nonce" do
    context "when the nonce matches the nonce in the session" do
      it "returns true" do
        expect(subject.send(:verify_nonce, session_nonce_digest)).to eq(true)
      end
    end

    context "when the nonce does not match the nonce in the session" do
      let(:jwt_nonce) { "456def" }

      it "raises an error" do
        expect { subject.send(:verify_nonce, session_nonce_digest) }.to raise_error(
          OmniAuth::GovukOneLogin::IdTokenNonceMismatchError
        )
      end
    end

    context "when the key is signed by any of the private_keys" do
      it "returns true" do
        aggregate_failures do
          IdpFixtures.private_keys.each do |private_key|
            JWT.encode({ nonce: jwt_nonce }, private_key, "ES256")
            expect(subject.send(:verify_nonce, session_nonce_digest)).to eq(true)
          end
        end
      end
    end

    context "when the key is signed by an invalid private_key" do
      let(:jwt) { JWT.encode({ nonce: jwt_nonce }, OpenSSL::PKey::EC.generate("prime256v1"), "ES256") }
      it "raises VerificationError" do
        expect do
          subject.send(:verify_nonce, session_nonce_digest)
        end.to raise_error(JWT::VerificationError)
      end
    end
  end

  describe "#decoded_id_token" do
    context "when all fields pass validation" do
      it "returns the decoded ID token" do
        expect(subject.send(:decoded_id_token)).to include(
          "aud" => jwt_aud,
          "exp" => jwt_exp,
          "iat" => jwt_iat,
          "iss" => jwt_iss,
          "nonce" => jwt_nonce,
          "vot" => jwt_vot
        )
      end
    end

    context "when the audience does not match the audience in the session" do
      let(:jwt_aud) { "fake-123" }

      it "raises an error" do
        expect { subject.send(:decoded_id_token) }.to raise_error(
          OmniAuth::GovukOneLogin::IdTokenAudMismatchError
        )
      end
    end

    context "when the token expiry time is in the past" do
      let(:jwt_exp) { Time.now.to_i - 60 }

      it "raises an error" do
        expect { subject.send(:decoded_id_token) }.to raise_error(
          OmniAuth::GovukOneLogin::IdTokenExpMismatchError
        )
      end
    end

    context "when the issued at is in the future" do
      let(:jwt_iat) { Time.now.to_i + 60 }

      it "raises an error" do
        expect { subject.send(:decoded_id_token) }.to raise_error(
          OmniAuth::GovukOneLogin::IdTokenIatMismatchError
        )
      end
    end

    context "when the issuer does not match the issuer in the session" do
      let(:jwt_iss) { "https://oidc.example.gov.uk/" }

      it "raises an error" do
        expect { subject.send(:decoded_id_token) }.to raise_error(
          OmniAuth::GovukOneLogin::IdTokenIssMismatchError
        )
      end
    end
  end

  describe "#verify_vector_of_trust" do
    context "when the vectors of trust match the vectors of trust in the session" do
      it "returns true" do
        expect(subject.send(:verify_vector_of_trust)).to eq(true)
      end
    end

    context "when the vectors of trust do not match the vectors of trust in the session" do
      let(:jwt_vot) { "Cl" }

      it "raises an error" do
        expect { subject.send(:verify_vector_of_trust) }.to raise_error(
          OmniAuth::GovukOneLogin::IdTokenVotMismatchError
        )
      end
    end
  end
end
