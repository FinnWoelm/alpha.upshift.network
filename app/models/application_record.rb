class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Sets created_at and updated_at to the given timestamps
  def timestamps=(timestamp)
    self.created_at = timestamp
    self.updated_at = timestamp
  end

  # returns true if the column with the specified name matches the specified
  # type
  def self.column_is_of_type? column, type
    self.columns.find{|c| c.name == column.to_s}.sql_type_metadata.type.to_s ==
      type.to_s
  end
end
