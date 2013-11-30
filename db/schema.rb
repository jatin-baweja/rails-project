# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20131127124726) do

  create_table "accounts", force: true do |t|
    t.string   "customer_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "card_id"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ckeditor_assets", force: true do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "display_images", force: true do |t|
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.integer  "project_id"
    t.boolean  "primary",              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "display_images", ["project_id"], name: "index_display_images_on_project_id", using: :btree

  create_table "messages", force: true do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.string   "subject"
    t.integer  "project_id"
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.boolean  "unread",       default: true
  end

  create_table "pledges", force: true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pledges", ["project_id"], name: "index_pledges_on_project_id", using: :btree
  add_index "pledges", ["user_id", "project_id"], name: "index_pledges_on_user_id_and_project_id", using: :btree
  add_index "pledges", ["user_id"], name: "index_pledges_on_user_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "title"
    t.string   "summary",       limit: 300
    t.string   "location_name"
    t.integer  "duration"
    t.datetime "deadline"
    t.integer  "goal"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.integer  "category_id"
    t.boolean  "approved",                  default: true
    t.boolean  "rejected",                  default: false
    t.datetime "published_at"
    t.boolean  "editing",                   default: true
    t.string   "video_url"
    t.string   "project_state"
  end

  add_index "projects", ["owner_id"], name: "index_projects_on_owner_id", using: :btree

  create_table "projects_users", id: false, force: true do |t|
    t.integer "project_id", null: false
    t.integer "user_id",    null: false
  end

  add_index "projects_users", ["user_id", "project_id"], name: "index_projects_users_on_user_id_and_project_id", unique: true, using: :btree

  create_table "requested_rewards", force: true do |t|
    t.integer  "pledge_id"
    t.integer  "reward_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity"
  end

  add_index "requested_rewards", ["pledge_id", "reward_id"], name: "index_requested_rewards_on_pledge_id_and_reward_id", unique: true, using: :btree
  add_index "requested_rewards", ["pledge_id"], name: "index_requested_rewards_on_pledge_id", using: :btree
  add_index "requested_rewards", ["reward_id"], name: "index_requested_rewards_on_reward_id", using: :btree

  create_table "rewards", force: true do |t|
    t.integer  "minimum_amount"
    t.text     "description"
    t.date     "estimated_delivery_on"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "remaining_quantity"
  end

  add_index "rewards", ["project_id"], name: "index_rewards_on_project_id", using: :btree

  create_table "stories", force: true do |t|
    t.text     "description"
    t.text     "risks"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.text     "why_we_need_help"
    t.text     "faq"
    t.text     "about_the_team"
  end

  add_index "stories", ["project_id"], name: "index_stories_on_project_id", using: :btree

  create_table "transactions", force: true do |t|
    t.integer  "pledge_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_mode",   default: "0"
    t.string   "transaction_id"
  end

  add_index "transactions", ["pledge_id"], name: "index_transactions_on_pledge_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",           default: false
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree

end
