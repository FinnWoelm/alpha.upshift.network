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

ActiveRecord::Schema.define(version: 20160722221025) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"
  enable_extension "uuid-ossp"

  create_table "comments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer  "author_id"
    t.uuid     "post_id"
    t.string   "content"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "likes_count", default: 0
    t.index ["author_id"], name: "index_comments_on_author_id", using: :btree
    t.index ["created_at"], name: "index_comments_on_created_at", using: :btree
    t.index ["post_id"], name: "index_comments_on_post_id", using: :btree
  end

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

  create_table "likes", force: :cascade do |t|
    t.integer  "liker_id"
    t.uuid     "likable_id"
    t.string   "likable_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["likable_type", "likable_id"], name: "index_likes_on_likable_type_and_likable_id", using: :btree
    t.index ["liker_id"], name: "index_likes_on_liker_id", using: :btree
  end

  create_table "posts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer  "author_id"
    t.text     "content",                 null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "likes_count", default: 0
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

  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users", column: "author_id"
  add_foreign_key "friendship_requests", "users", column: "recipient_id"
  add_foreign_key "friendship_requests", "users", column: "sender_id"
  add_foreign_key "friendships", "users", column: "acceptor_id"
  add_foreign_key "friendships", "users", column: "initiator_id"
  add_foreign_key "likes", "users", column: "liker_id"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "profiles", "users"
end
