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

ActiveRecord::Schema.define(version: 20160721230542) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"
  enable_extension "uuid-ossp"

  create_table "friendship_requests", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["recipient_id"], name: "index_friendship_requests_on_recipient_id", using: :btree
    t.index ["sender_id"], name: "index_friendship_requests_on_sender_id", using: :btree
  end

  create_table "friendships", force: :cascade do |t|
    t.integer  "initiator_id"
    t.integer  "acceptor_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["acceptor_id"], name: "index_friendships_on_acceptor_id", using: :btree
    t.index ["initiator_id"], name: "index_friendships_on_initiator_id", using: :btree
  end

  create_table "posts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer  "author_id"
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_posts_on_author_id", using: :btree
    t.index ["created_at"], name: "index_posts_on_created_at", using: :btree
  end

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "visibility", default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.citext   "username",        null: false
    t.string   "password_digest"
    t.string   "name"
    t.datetime "last_seen_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  add_foreign_key "friendship_requests", "users", column: "recipient_id"
  add_foreign_key "friendship_requests", "users", column: "sender_id"
  add_foreign_key "friendships", "users", column: "acceptor_id"
  add_foreign_key "friendships", "users", column: "initiator_id"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "profiles", "users"
end
