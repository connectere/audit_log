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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120714003030) do

  create_table "audited_models", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "ignored_field"
  end

  create_table "has_one_audited_models", :force => true do |t|
    t.string   "description"
    t.integer  "audited_model_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "logged_models", :force => true do |t|
    t.string   "what"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "model_id"
    t.string   "model_class_name"
    t.integer  "who"
  end

  create_table "nested_audited_models", :force => true do |t|
    t.string   "nested_description"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "ignored_field"
    t.integer  "audited_model_id"
  end

end
