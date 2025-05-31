module OmniAuth
  module GovukOneLogin
    Userinfo = Struct.new(
      :uuid,
      :email,
      :email_verified
    ) do
      def initialize(
        uuid: nil,
        email: nil,
        email_verified: nil
      )
        self.uuid = uuid
        self.email = email
        self.email_verified = email_verified
      end

      def to_h
        super().merge(name: email || uuid)
      end
    end
  end
end
