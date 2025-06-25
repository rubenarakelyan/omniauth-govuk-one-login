module OmniAuth
  module GovukOneLogin
    class SecureCompare
      # Borrowed from Devise.secure_compare
      # Ref: https://github.com/heartcombo/devise/blob/cf93de390a29654620fdf7ac07b4794eb95171d0/lib/devise.rb#L520-L527
      # rubocop:disable Naming/PredicateMethod
      def self.secure_compare(a, b)
        return false if a.blank? || b.blank? || a.bytesize != b.bytesize

        l = a.unpack "C#{a.bytesize}"

        res = 0
        b.each_byte { |byte| res |= byte ^ l.shift }
        res.zero?
      end
      # rubocop:enable Naming/PredicateMethod
    end
  end
end
