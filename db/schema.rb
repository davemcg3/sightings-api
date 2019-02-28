# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_23_082117) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "sightings", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "subtype_id"
    t.integer "zipcode", null: false
    t.text "notes"
    t.integer "number_sighted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["subject_id"], name: "index_sightings_on_subject_id"
    t.index ["subtype_id"], name: "index_sightings_on_subtype_id"
    t.index ["user_id"], name: "index_sightings_on_user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subtypes", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.index ["parent_id"], name: "index_subtypes_on_parent_id"
    t.index ["subject_id"], name: "index_subtypes_on_subject_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "display_name"
    t.integer "admin", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "sightings", "subjects"
  add_foreign_key "sightings", "subtypes"
  add_foreign_key "sightings", "users"
  add_foreign_key "subtypes", "subjects"
  add_foreign_key "subtypes", "subtypes", column: "parent_id"
end
