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

ActiveRecord::Schema.define(version: 20131122113330) do

  #FIXME_AB: Why can't we use users table for admins. We just need to add one column to identify user /admin
  create_table "admins", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  #FIXME_AB: why don't we have created_at and updated_at column
  create_table "categories", force: true do |t|
    t.string "name"
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

  create_table "messages", force: true do |t|
    t.text     "content"
    #FIXME_AB: Lets discuss why we have named it as project_conversations_id
    t.integer  "project_conversation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    #FIXME_AB: What is the significance of this column?
    t.boolean  "from_converser",          default: true
  end

  add_index "messages", ["project_conversation_id"], name: "index_messages_on_project_conversation_id", using: :btree

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

  #FIXME_AB: Lets discuss project conversation db architecture
  create_table "project_conversations", force: true do |t|
    t.integer  "converser_id"
    t.string   "converser_type"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_conversations", ["converser_id", "converser_type"], name: "index_project_conversations_on_converser_id_and_converser_type", using: :btree
  add_index "project_conversations", ["project_id"], name: "index_project_conversations_on_project_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "title"
    t.string   "summary",            limit: 300
    t.string   "location_name"
    t.integer  "duration"
    t.datetime "deadline"
    t.integer  "goal"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.integer  "category_id"
    #FIXME_AB: What if we would like to have multiple images for a project
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    #FIXME_AB: we can just name it as approved
    t.boolean  "pending_approval",               default: true
    #FIXME_AB: What is the difference between name and title
    t.string   "name"
    t.boolean  "rejected",                       default: false
    #FIXME_AB: Since it is datetime field so it should be called something like published_at
    t.datetime "publish_on"
    #FIXME_AB: editing?
    t.boolean  "editing",                        default: true
    #FIXME_AB: I think we are having video url so should we name it.
    t.string   "video"
  end

  add_index "projects", ["owner_id"], name: "index_projects_on_owner_id", using: :btree

  create_table "projects_users", id: false, force: true do |t|
    t.integer "project_id", null: false
    t.integer "user_id",    null: false
  end

  add_index "projects_users", ["user_id", "project_id"], name: "index_projects_users_on_user_id_and_project_id", unique: true, using: :btree

  #FIXME_AB: need to discuss why we need this table
  create_table "requested_rewards", force: true do |t|
    t.integer  "pledge_id"
    t.integer  "reward_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "requested_rewards", ["pledge_id", "reward_id"], name: "index_requested_rewards_on_pledge_id_and_reward_id", unique: true, using: :btree
  add_index "requested_rewards", ["pledge_id"], name: "index_requested_rewards_on_pledge_id", using: :btree
  add_index "requested_rewards", ["reward_id"], name: "index_requested_rewards_on_reward_id", using: :btree

  create_table "rewards", force: true do |t|
    #FIXME_AB: if this is the minimum amount to be pledge for this reward then it should be reflect in the name
    t.integer  "minimum"
    t.text     "description"
    t.date     "estimated_delivery_on"
    #FIXME_AB: shipping? 
    t.string   "shipping"
    #FIXME_AB: limit?
    t.integer  "limit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
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

  #FIXME_AB: Lets also discuss this table
  create_table "stripe_accounts", force: true do |t|
    t.string   "customer_token"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "card_token"
  end

  create_table "transactions", force: true do |t|
    t.integer  "pledge_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "card_used",         default: false
    t.string   "transaction_token"
  end

  add_index "transactions", ["pledge_id"], name: "index_transactions_on_pledge_id", using: :btree

  #FIXME_AB: no index on users table
  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
