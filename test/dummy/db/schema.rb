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

ActiveRecord::Schema.define(version: 2021_06_15_165924) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alerts", force: :cascade do |t|
    t.string "alertable_type", null: false
    t.bigint "alertable_id", null: false
    t.boolean "resolved", default: false
    t.string "message"
    t.string "kind", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alertable_type", "alertable_id"], name: "index_alerts_on_alertable"
  end

  create_table "orders", force: :cascade do |t|
    t.string "customer"
    t.date "placed"
    t.boolean "paid"
    t.boolean "refunded"
    t.boolean "shipped"
    t.boolean "returned"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "special_alerts", force: :cascade do |t|
    t.string "alertable_type", null: false
    t.bigint "alertable_id", null: false
    t.boolean "resolved", default: false
    t.string "message"
    t.integer "kind"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alertable_type", "alertable_id"], name: "index_special_alerts_on_alertable"
  end

  create_table "task_lists", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.date "due_date"
    t.boolean "done"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "task_list_id"
    t.index ["task_list_id"], name: "index_tasks_on_task_list_id"
  end

end
