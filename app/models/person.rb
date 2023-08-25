class Person < ApplicationRecord
  self.table_name = :persons_with_fts

  include PgSearch::Model

  multisearchable against: 'Information'
  # pg_search_scope :info_search, against: 'Information'
  has_one :base, foreign_key: :Base, primary_key: :Base
end
