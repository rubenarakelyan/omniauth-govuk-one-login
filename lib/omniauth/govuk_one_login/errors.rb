module OmniAuth
  module GovukOneLogin
    class Error < StandardError
      def key
        self.class.name.demodulize.underscore.gsub(/_error$/, "").to_sym
      end
    end

    class OpenidDiscoveryError < Error
    end

    class CallbackStateMismatchError < Error
    end

    class CallbackAccessDeniedError < Error
    end

    class CallbackInvalidRequestError < Error
    end

    class CallbackServiceUnavailableError < Error
    end

    class CallbackLoginRequiredError < Error
    end

    class IdTokenRequestError < Error
    end

    class IdTokenNonceMismatchError < Error
    end

    class IdTokenIssMismatchError < Error
    end

    class IdTokenAudMismatchError < Error
    end

    class IdTokenIatMismatchError < Error
    end

    class IdTokenExpMismatchError < Error
    end

    class IdTokenVotMismatchError < Error
    end

    class UserinfoRequestError < Error
    end

    class LogoutTokenExpMismatchError < Error
    end

    class LogoutTokenAudMismatchError < Error
    end

    class LogoutTokenIatMismatchError < Error
    end

    class LogoutTokenIssMismatchError < Error
    end

    class LogoutTokenSubMismatchError < Error
    end

    class LogoutTokenEventsClaimMismatchError < Error
    end
  end
end
