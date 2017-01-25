RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|

    # Use really fast transaction strategy for all examples expect 'js: true'
    # Capybara specs.
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction

    # Start transaction/truncation
    DatabaseCleaner.cleaning do

      # Run example
      example.run
    end

    # Clear session data
    Capybara.reset_sessions!
  end

end
