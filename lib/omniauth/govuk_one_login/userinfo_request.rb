module OmniAuth
  module GovukOneLogin
    class UserinfoRequest
      attr_reader :id_token, :client

      def initialize(id_token:, client:)
        @id_token = id_token
        @client = client
      end

      def request_userinfo
        response = Faraday.get(
          client.idp_configuration.userinfo_endpoint,
          {},
          Authorization: "Bearer #{id_token.access_token}"
        )
        raise_userinfo_request_failed_error(response) unless response.success?
        userinfo_from_response(response)
      end

      private

      def userinfo_from_response(response)
        parsed_body = JSON.parse(response.body)
        Userinfo.new(
          uuid: parsed_body["sub"],
          email: parsed_body["email"],
          email_verified: parsed_body["email_verified"]
        )
      end

      def raise_userinfo_request_failed_error(response)
        status_code = response.status
        message = "Userinfo request failed with status code: #{status_code}"
        raise UserinfoRequestError, message
      end
    end
  end
end
