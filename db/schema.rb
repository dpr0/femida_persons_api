# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_08_17_075306) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "Base_Schemes", id: false, force: :cascade do |t|
    t.integer "ID"
    t.text "Base"
    t.text "Schema"
    t.integer "Year"
    t.index ["Base"], name: "schema_base_idx"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "persons_with_fts", id: false, force: :cascade do |t|
    t.bigint "ID"
    t.text "FirstName"
    t.text "LastName"
    t.text "MiddleName"
    t.text "Telephone"
    t.text "Car"
    t.text "Passport"
    t.integer "DayBirth", limit: 2
    t.integer "MonthBirth", limit: 2
    t.integer "YearBirth", limit: 2
    t.text "SNILS"
    t.text "INN"
    t.text "Information"
    t.text "Base"
    t.tsvector "referat_fts_vector"
    t.index ["Base"], name: "persons_base_idx", where: "(\"Base\" IS NOT NULL)"
    t.index ["Car"], name: "persons_cars_gin_idx", opclass: :gin_trgm_ops, where: "(\"Car\" IS NOT NULL)", using: :gin
    t.index ["Car"], name: "persons_cars_idx", where: "(\"Car\" IS NOT NULL)"
    t.index ["FirstName", "MiddleName", "YearBirth", "MonthBirth", "DayBirth"], name: "persons_ioymds_idx"
    t.index ["ID"], name: "persons_ids_idx", where: "(\"ID\" IS NOT NULL)"
    t.index ["INN"], name: "persons_inns_idx", where: "(\"INN\" IS NOT NULL)"
    t.index ["LastName", "FirstName", "MiddleName"], name: "persons_fios_idx"
    t.index ["LastName", "YearBirth", "MonthBirth", "DayBirth"], name: "persons_fymds_idx"
    t.index ["Passport"], name: "persons_passports_idx", where: "(\"Passport\" IS NOT NULL)"
    t.index ["SNILS"], name: "persons_snilss_idx", where: "(\"SNILS\" IS NOT NULL)"
    t.index ["Telephone"], name: "persons_telephones_gin_idx", opclass: :gin_trgm_ops, where: "(\"Telephone\" IS NOT NULL)", using: :gin
    t.index ["Telephone"], name: "persons_with_fts_telephone_idx", where: "(\"Telephone\" IS NOT NULL)"
    t.index ["referat_fts_vector"], name: "persons_referat_fts_idx", using: :gin
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
