class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Sets created_at and updated_at to the given timestamps
  def timestamps=(timestamp)
    self.created_at = timestamp
    self.updated_at = timestamp
  end
end
