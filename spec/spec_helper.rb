ENV["RAILS_ENV"] ||= 'test'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift File.dirname(__FILE__)

require File.expand_path("../../config/environment", __FILE__) 

require 'rspec/rails'

require 'capybara/rspec'
require 'capybara/rails'

require 'ruby-saml'
require 'ruby-saml-idp'

require 'nokogiri'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.mock_with :rspec

  config.include SamlRequestMacros

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
