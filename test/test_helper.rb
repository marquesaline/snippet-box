ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    setup do
      ActiveStorage::Current.url_options = { host: "test.host", protocol: "http" }
    end

    teardown do
      FileUtils.rm_rf(ActiveStorage::Blob.service.root)
    end
  end
end

module ActionDispatch
  class IntegrationTest
    setup do
      host! "test.host"
    end
  end
end
