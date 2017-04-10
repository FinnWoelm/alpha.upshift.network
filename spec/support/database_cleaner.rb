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

    # Delete Paperclip attachments
    load Rails.root.join("spec", "support", "paperclip", "clean.rb")

    # Clear session data
    Capybara.reset_sessions!
  end

end
