class Base < ApplicationRecord
  self.table_name = :Base_Schemes

  belongs_to :person
end
