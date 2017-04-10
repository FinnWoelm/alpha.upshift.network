require "database_cleaner"
require "factory_girl"
require "faker"

MagicLamp.configure do |config|

  DatabaseCleaner.strategy = :transaction

  config.before_each do
    DatabaseCleaner.start
    # change the attachment storage location so that all attachments can easily
    # be cleaned upon completion
    load Rails.root.join("spec", "support", "paperclip", "init.rb")
  end

  config.after_each do
    DatabaseCleaner.clean
    # clean all attachments
    load Rails.root.join("spec", "support", "paperclip", "clean.rb")
  end

end
