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

ActiveRecord::Schema.define(version: 2018_09_27_203619) do

  create_table "assignments", force: :cascade do |t|
    t.datetime "assignment_time"
    t.string "message_id"
    t.string "assigned_to"
    t.string "assigned_from"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "auth_tokens", force: :cascade do |t|
    t.string "refresh_token"
    t.string "access_token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string "message_id"
    t.string "assigned_to"
    t.string "reply_to"
    t.string "reply"
    t.string "labels"
    t.integer "status"
    t.string "contact_email"
    t.string "thread_id"
    t.string "message_time"
    t.string "assignment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subject"
    t.string "snippet"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "pending_messages"
    t.string "replied_messages"
    t.string "unassigned_messages"
    t.string "transferred_messages"
    t.integer "pending_count"
    t.integer "replied_count"
    t.integer "unassigned_count"
    t.integer "transferred_count"
    t.datetime "last_login_time"
    t.datetime "last_activity_time"
    t.string "last_history_id"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.string "signature"
  end

end
