# GOV.UK One Login OmniAuth strategy

[![Gem Version](https://badge.fury.io/rb/omniauth_govuk_one_login.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/omniauth_govuk_one_login)

This gem is an OmniAuth strategy to provide authentication with GOV.UK One Login using the OpenID Connect protocol.

Heavily inspired by [omniauth_login_dot_gov](https://github.com/18F/omniauth_login_dot_gov).

## Getting started in a Rails app

There is excellent documentation at <https://docs.sign-in.service.gov.uk/> for getting started with GOV.UK One Login as
well as explanations of all the options and the login/logout flows.

### Generate your keypair

```bash
openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in private_key.pem -out public_key.pem
```

### Sign up for GOV.UK One Login and configure your service

1. Visit <https://admin.sign-in.service.gov.uk/> and sign up with an eligible government email address.
2. Create a new service to get your client ID.
3. Add `http://localhost:3000/auth/govuk_one_login/callback` as a redirect URI.
4. Add your public key.

### Configure your app

1. Add environment variables to your application for details needed by this gem:
  ```
  GOVUK_ONE_LOGIN_CLIENT_ID=clientid
  GOVUK_ONE_LOGIN_BASE_URL=https://oidc.integration.account.gov.uk/
  GOVUK_ONE_LOGIN_REDIRECT_URI=http://localhost:3000/auth/govuk_one_login/callback
  GOVUK_ONE_LOGIN_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
  blah
  -----END PRIVATE KEY-----"
  ```
2. Add this gem to the Gemfile:
  ```ruby
  gem "omniauth_govuk_one_login"
  ```
3. Additionally, add the OmniAuth CSRF protection gem to the Gemfile:
  ```ruby
  gem "omniauth-rails_csrf_protection"
  ```
4. Install these gems and dependencies with `bundle install`
5. Now, configure the OmniAuth middleware with an initializer:
  ```ruby
  # config/initializers/omniauth.rb
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :govuk_one_login, {
      name: :govuk_one_login,
      client_id: ENV["GOVUK_ONE_LOGIN_CLIENT_ID"], # your client ID from the GOV.UK One Login admin tool
      idp_base_url: ENV["GOVUK_ONE_LOGIN_BASE_URL"],
      private_key: OpenSSL::PKey::RSA.new(ENV["GOVUK_ONE_LOGIN_PRIVATE_KEY"]), # the private key you generated above in PEM format
      redirect_uri: ENV["GOVUK_ONE_LOGIN_REDIRECT_URI"],
      # these are optional - shown here with their default values if omitted
      scope: "openid,email", # comma-separated; must include at least `openid` and `email`
      ui_locales: "en", # comma-separated; can also include `cy` for Welsh UI
      vtr: ["Cl.Cm"], # array with one element; dot-separated; can also include identity vectors such as `P2` (eg. `Cl.Cm.P2`)
      pkce: false, # set to `true` to enable "Proof Key for Code Exchange)
      userinfo_claims: [] # array of URLs; see https://docs.sign-in.service.gov.uk/integrate-with-integration-environment/authenticate-your-user/#create-a-url-encoded-json-object-for-lt-claims-request-gt
    }

    # will call `Users::OmniauthController#failure` if there are any errors during the login process
    on_failure { |env| Users::OmniauthController.action(:failure).call(env) }
  end
  ```
6. Create a controller for handling the callback, such as this:
  ```ruby
  # app/controllers/users/omniauth_controller.rb
  module Users
    class OmniauthController < ApplicationController
      def callback
        omniauth_info = request.env["omniauth.auth"]["info"]
        @user = User.find_by(email: omniauth_info["email"])
        if @user
          @user.update!(uuid: omniauth_info["uuid"])
          sign_in @user
          redirect_to service_providers_path

        # Can't find an account, tell user to contact GOV.UK One Login
        else
          redirect_to users_none_url
        end
      end

      def failure
        # do something here
      end
    end
  end
  ```
7. Add the callback route to `routes.rb`
  ```ruby
  get "/auth/govuk_one_login/callback", to: "users/omniauth#callback"
  ```
8. Start your application and send a `POST` request to: `/auth/govuk_one_login` (eg. http://localhost:3000/auth/govuk_one_login) to initiate authentication with GOV.UK One Login.

## More information and examples

The [wiki](https://github.com/rubenarakelyan/omniauth-govuk-one-login/wiki) contains more information and examples of using this gem in your application, including existing user migrations.

## Note on gem signing and verification

This gem is cryptographically signed. To be sure the gem you install hasn’t been tampered with, run:
```bash
gem cert --add <(curl -Ls https://raw.github.com/rubenarakelyan/omniauth-govuk-one-login/main/certs/rubena.pem)
gem install omniauth_govuk_one_login -P MediumSecurity
```

The `MediumSecurity` trust profile will verify signed gems, but allow the installation of unsigned dependencies.

This is necessary because not all of this gem’s dependencies are signed, so we cannot use `HighSecurity`.

## Licence

This gem is licensed under the [MIT licence](LICENSE).
