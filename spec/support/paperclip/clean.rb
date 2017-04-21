# clean all attachments
FileUtils.rm_rf(Dir["#{Rails.root}#{Rails.configuration.attachment_storage_location}[^.]*"])
