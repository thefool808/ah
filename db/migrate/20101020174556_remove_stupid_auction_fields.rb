class RemoveStupidAuctionFields < ActiveRecord::Migration
  def self.up
    remove_column :auctions, :current_bid
    remove_column :auctions, :next_minimum_bid
    remove_column :auctions, :per_unit_bid
    remove_column :auctions, :per_unit_buyout
    remove_column :auctions, :charges
    remove_column :auctions, :remaining_time_code
  end

  def self.down
    add_column :auctions, :current_bid, :integer
    add_column :auctions, :next_minimum_bid, :integer
    add_column :auctions, :per_unit_bid, :integer
    add_column :auctions, :per_unit_buyout, :integer
    add_column :auctions, :charges, :integer
    add_column :auctions, :remaining_time_code, :integer
  end
end
