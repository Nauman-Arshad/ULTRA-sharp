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

ActiveRecord::Schema[8.1].define(version: 2026_02_27_121000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "line_total", precision: 14, scale: 2, default: "0.0", null: false
    t.bigint "order_id", null: false
    t.bigint "product_id"
    t.string "product_name", null: false
    t.decimal "quantity", precision: 14, scale: 2, null: false
    t.decimal "unit_price", precision: 14, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.decimal "advance_payment", precision: 14, scale: 2
    t.datetime "created_at", null: false
    t.date "order_date"
    t.string "order_number"
    t.string "order_status"
    t.bigint "party_id", null: false
    t.string "payment_status"
    t.decimal "remaining_amount", precision: 14, scale: 2
    t.decimal "total_amount", precision: 14, scale: 2
    t.datetime "updated_at", null: false
    t.index ["party_id"], name: "index_orders_on_party_id"
  end

  create_table "parties", force: :cascade do |t|
    t.decimal "account_balance", precision: 14, scale: 2, default: "0.0", null: false
    t.text "address"
    t.datetime "created_at", null: false
    t.string "party_name"
    t.string "phone"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_parties_on_phone", unique: true, where: "(phone IS NOT NULL)"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 14, scale: 2
    t.datetime "created_at", null: false
    t.bigint "order_id"
    t.bigint "party_id", null: false
    t.date "payment_date"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["party_id"], name: "index_payments_on_party_id"
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.decimal "unit_price", precision: 14, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "parties"
  add_foreign_key "payments", "orders"
  add_foreign_key "payments", "parties"
  add_foreign_key "sessions", "users"
end
