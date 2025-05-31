require "active_support/core_ext/hash/keys"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/object/to_query"
require "pry-byebug"
require "webmock"
require "webmock/rspec"
require "omniauth_govuk_one_login"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.order = :random
  config.color = true

  # allows you to run only the failures from the previous run:
  # rspec --only-failures
  config.example_status_persistence_file_path = "./tmp/rspec-examples.txt"
end

WebMock.disable_net_connect!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].sort.each { |file| require file }
