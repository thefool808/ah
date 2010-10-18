class CreateAuctions < ActiveRecord::Migration
  def self.up
    create_table :auctions do |t|
      t.integer :auction_id
      t.integer :item_id
      t.integer :quantity
      t.integer :current_bid
      t.integer :next_minimum_bid
      t.integer :buyout
      t.integer :per_unit_bid
      t.integer :per_unit_buyout
      t.integer :charges
      t.string  :seller_name
      t.integer :remaining_time_code
      t.timestamps
    end
    add_index (:auctions, :auction_id, :unique => true)
    add_index (:auctions, :item_id)
  end

  def self.down
    drop_table :auctions
  end
end
