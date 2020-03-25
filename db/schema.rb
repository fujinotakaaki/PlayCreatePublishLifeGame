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

ActiveRecord::Schema.define(version: 2020_03_23_110715) do

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "explanation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "display_formats", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.string "alive"
    t.string "dead"
    t.string "font_color", default: "#90EE90"
    t.string "background_color", default: "#000"
    t.string "line_height_rate", default: "100"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "pattern_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "makings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "is_torus", default: false, null: false
    t.integer "margin_top", default: 0
    t.integer "margin_bottom", default: 0
    t.integer "margin_left", default: 0
    t.integer "margin_right", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "normalized_rows_sequence"
  end

  create_table "patterns", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "category_id", default: 1, null: false
    t.integer "display_format_id", default: 1, null: false
    t.string "name"
    t.text "introduction"
    t.string "image_id"
    t.boolean "is_torus", default: false, null: false
    t.integer "margin_top"
    t.integer "margin_bottom"
    t.integer "margin_left"
    t.integer "margin_right"
    t.boolean "is_secret", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "normalized_rows_sequence"
  end

  create_table "post_comments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "pattern_id", null: false
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.text "introduction"
    t.string "profile_image_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
