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

ActiveRecord::Schema.define(version: 20170523161941) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"
  enable_extension "uuid-ossp"
  enable_extension "unaccent"

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "author_id"
    t.string "commentable_id"
    t.string "commentable_type"
    t.string "content"
    t.integer "likes_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_comments_on_author_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
  end

  create_table "democracy_communities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_democracy_communities_on_created_at"
  end

  create_table "democracy_community_decisions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "community_id"
    t.integer "author_id"
    t.string "title"
    t.text "description"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "votes_count", default: "---\n:total: 0\n:upvotes: 0\n:downvotes: 0\n"
    t.index ["author_id"], name: "index_democracy_community_decisions_on_author_id"
    t.index ["community_id"], name: "index_democracy_community_decisions_on_community_id"
    t.index ["created_at"], name: "index_democracy_community_decisions_on_created_at"
  end

  create_table "friendship_requests", id: :serial, force: :cascade do |t|
    t.integer "sender_id"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_friendship_requests_on_recipient_id"
    t.index ["sender_id"], name: "index_friendship_requests_on_sender_id"
  end

  create_table "friendships", id: :serial, force: :cascade do |t|
    t.integer "initiator_id"
    t.integer "acceptor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["acceptor_id"], name: "index_friendships_on_acceptor_id"
    t.index ["initiator_id"], name: "index_friendships_on_initiator_id"
  end

  create_table "helper_blacklisted_usernames", id: :serial, force: :cascade do |t|
    t.citext "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_helper_blacklisted_usernames_on_username", unique: true
  end

  create_table "likes", id: :serial, force: :cascade do |t|
    t.integer "liker_id"
    t.string "likable_id"
    t.string "likable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["likable_type", "likable_id"], name: "index_likes_on_likable_type_and_likable_id"
    t.index ["liker_id"], name: "index_likes_on_liker_id"
  end

  create_table "notification_actions", id: :serial, force: :cascade do |t|
    t.integer "actor_id"
    t.integer "notification_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notification_actions_on_created_at"
    t.index ["notification_id", "actor_id"], name: "index_notification_actions_on_notification_id_and_actor_id", unique: true
  end

  create_table "notification_subscriptions", id: :serial, force: :cascade do |t|
    t.integer "subscriber_id"
    t.integer "notification_id"
    t.integer "reason_for_subscription"
    t.datetime "seen_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id", "subscriber_id"], name: "index_notification_subscriptions_on_notification_and_subscriber", unique: true
    t.index ["notification_id"], name: "index_notification_subscriptions_on_notification_id"
    t.index ["subscriber_id"], name: "index_notification_subscriptions_on_subscriber_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.string "notifier_type"
    t.string "notifier_id"
    t.integer "action_on_notifier"
    t.datetime "others_acted_before"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifier_type", "notifier_id", "action_on_notifier"], name: "index_notifications_on_notifier_and_action", unique: true
  end

  create_table "participantship_in_private_conversations", id: :serial, force: :cascade do |t|
    t.integer "participant_id"
    t.uuid "private_conversation_id"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id", "private_conversation_id"], name: "index_participantship_in_private_conversations_first", unique: true
    t.index ["private_conversation_id"], name: "index_participantship_in_private_conversations_second"
  end

  create_table "pending_newsletter_subscriptions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "confirmation_token"
    t.string "signup_url"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_pending_newsletter_subscriptions_on_confirmation_token", unique: true
    t.index ["email"], name: "index_pending_newsletter_subscriptions_on_email", unique: true
  end

  create_table "posts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "author_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes_count"
    t.integer "recipient_id"
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["recipient_id"], name: "index_posts_on_recipient_id"
  end

  create_table "private_conversations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_private_conversations_on_created_at"
  end

  create_table "private_messages", id: :serial, force: :cascade do |t|
    t.uuid "private_conversation_id"
    t.integer "sender_id"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["private_conversation_id"], name: "index_private_messages_on_private_conversation_id"
    t.index ["sender_id"], name: "index_private_messages_on_sender_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.citext "username", null: false
    t.string "password_digest"
    t.string "name"
    t.datetime "last_seen_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "profile_picture_file_name"
    t.string "profile_picture_content_type"
    t.integer "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.string "color_scheme", default: "indigo basic", null: false
    t.integer "visibility", default: 0
    t.text "options"
    t.string "profile_banner_file_name"
    t.string "profile_banner_content_type"
    t.integer "profile_banner_file_size"
    t.datetime "profile_banner_updated_at"
    t.text "bio"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.integer "voter_id"
    t.uuid "votable_id"
    t.string "votable_type"
    t.integer "vote", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["votable_type", "votable_id"], name: "index_votes_on_votable_type_and_votable_id"
    t.index ["voter_id"], name: "index_votes_on_voter_id"
  end

  add_foreign_key "comments", "users", column: "author_id"
  add_foreign_key "democracy_community_decisions", "democracy_communities", column: "community_id"
  add_foreign_key "democracy_community_decisions", "users", column: "author_id"
  add_foreign_key "friendship_requests", "users", column: "recipient_id"
  add_foreign_key "friendship_requests", "users", column: "sender_id"
  add_foreign_key "friendships", "users", column: "acceptor_id"
  add_foreign_key "friendships", "users", column: "initiator_id"
  add_foreign_key "likes", "users", column: "liker_id"
  add_foreign_key "notification_actions", "notifications"
  add_foreign_key "notification_actions", "users", column: "actor_id"
  add_foreign_key "notification_subscriptions", "notifications"
  add_foreign_key "notification_subscriptions", "users", column: "subscriber_id"
  add_foreign_key "participantship_in_private_conversations", "private_conversations"
  add_foreign_key "participantship_in_private_conversations", "users", column: "participant_id"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "posts", "users", column: "recipient_id"
  add_foreign_key "private_messages", "private_conversations"
  add_foreign_key "private_messages", "users", column: "sender_id"
  add_foreign_key "votes", "users", column: "voter_id"
end
