class Person < ApplicationRecord
  self.table_name = :persons_with_fts

  has_one :base, foreign_key: :Base, primary_key: :Base
end
