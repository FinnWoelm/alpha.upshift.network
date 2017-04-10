# clean all attachments
FileUtils.rm_rf(Dir["#{Rails.root}/public/test/[^.]*"])
