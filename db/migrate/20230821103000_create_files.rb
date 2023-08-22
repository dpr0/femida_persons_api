# frozen_string_literal: true

class CreateFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :files do |t|
      t.integer :user_id
      t.date :date
      t.string :info
      t.string :filename
      t.string :content_type
      t.string :url
      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
