lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "omniauth/govuk_one_login/version"

Gem::Specification.new do |s|
  s.name = "omniauth_govuk_one_login"
  s.summary = "GOV.UK One Login OmniAuth strategy"
  s.version = OmniAuth::GovukOneLogin::VERSION
  s.author = "Ruben Arakelyan"
  s.description = "An OmniAuth strategy for GOV.UK One Login"
  s.email = "ruben@arakelyan.uk"
  s.homepage = "https://github.com/rubenarakelyan/omniauth-govuk-one-login"
  s.license = "MIT"
  s.required_ruby_version = ">= 3.2.8"
  s.platform = Gem::Platform::RUBY
  s.files = Dir.glob("lib/**/*") + [
    "CHANGELOG.md",
    "Gemfile",
    "LICENSE",
    "README.md",
    "omniauth_govuk_one_login.gemspec"
  ]
  s.require_paths = ["lib"]
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/rubenarakelyan/omniauth-govuk-one-login/issues",
    "changelog_uri" => "https://github.com/rubenarakelyan/omniauth-govuk-one-login/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/omniauth_govuk_one_login",
    "source_code_uri" => "https://github.com/rubenarakelyan/omniauth-govuk-one-login",
    "wiki_uri" => "https://github.com/rubenarakelyan/omniauth-govuk-one-login/wiki",
    "funding_uri" => "https://github.com/sponsors/rubenarakelyan",
    "rubygems_mfa_required" => "true"
  }

  s.cert_chain = ["certs/rubena.pem"]
  s.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/

  s.add_dependency "faraday", "~> 2.13"
  s.add_dependency "jwt", ">= 2.10", "< 4.0"
  s.add_dependency "omniauth", "~> 2.1"

  s.add_development_dependency "activesupport", "~> 8.0"
  s.add_development_dependency "pry-byebug", "~> 3.11"
  s.add_development_dependency "rake", "~> 13.3"
  s.add_development_dependency "rspec", "~> 3.13"
  s.add_development_dependency "rubocop", "~> 1.76"
  s.add_development_dependency "simplecov", "~> 0.22"
  s.add_development_dependency "webmock", "~> 3.25"
end
