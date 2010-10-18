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

ActiveRecord::Schema.define(:version => 20101018191112) do

  create_table "auctions", :force => true do |t|
    t.integer "auction_id"
    t.integer "item_id"
    t.integer "quantity"
    t.integer "current_bid"
    t.integer "next_minimum_bid"
    t.integer "buyout"
    t.integer "per_unit_bid"
    t.integer "per_unit_buyout"
    t.integer "charges"
    t.string  "seller_name"
    t.integer "remaining_time_code"
    t.integer "first_seen_scan_id"
    t.integer "last_seen_scan_id"
  end

  add_index "auctions", ["auction_id"], :name => "index_auctions_on_auction_id", :unique => true
  add_index "auctions", ["item_id"], :name => "index_auctions_on_item_id"

  create_table "items", :force => true do |t|
    t.integer "item_id"
    t.string  "name"
    t.integer "item_level"
    t.string  "icon"
    t.integer "required_level"
    t.integer "quality_code"
  end

  add_index "items", ["item_id"], :name => "index_items_on_item_id", :unique => true
  add_index "items", ["name"], :name => "index_items_on_name"

  create_table "scans", :force => true do |t|
    t.integer  "auction_count"
    t.datetime "started_at"
    t.datetime "finished_at"
  end

end
