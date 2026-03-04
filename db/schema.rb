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

ActiveRecord::Schema[8.1].define(version: 2026_03_04_165012) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "todo_items", force: :cascade do |t|
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.text "description"
    t.date "end_date"
    t.string "external_id"
    t.date "start_date"
    t.string "state", default: "Ready for start", null: false
    t.text "sync_error"
    t.datetime "synced_at"
    t.string "title", null: false
    t.integer "todo_list_id", null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["external_id"], name: "index_todo_items_on_external_id"
    t.index ["todo_list_id"], name: "index_todo_items_on_todo_list_id"
  end

  create_table "todo_lists", force: :cascade do |t|
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.string "external_id"
    t.string "name", null: false
    t.text "sync_error"
    t.datetime "synced_at"
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["external_id"], name: "index_todo_lists_on_external_id"
  end

  add_foreign_key "todo_items", "todo_lists"
end
