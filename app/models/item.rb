class Item < ActiveRecord::Base
  has_many :auctions, :order => 'last_seen_scan_id DESC, per_unit_buyout'

  def search_auction_house
    AuctionHouse.new.login!.search(Query.for_item(self))
  end

  def self.find_or_create_from_auction_hash(auction_hash)
    i = find_by_item_id(auction_hash["id"])
    unless i
      i = new(extract_attributes_from_auction_hash(auction_hash))
      i.save
    end
    return i
  end

  def current_auctions
    self.auctions.delete_if{|a| a.last_seen_scan_id != Scan.latest_scan_id}
  end

  def current_buyouts
    current_auctions.inject(StatArray.new){|ar, a| a.quantity.times {ar << a.per_unit_buyout}; ar}
  end

  def current_median_buyout
    current_buyouts.median
  end

  def current_mean_buyout
    current_buyouts.mean
  end

  def overall_buyouts
    auctions.inject(StatArray.new){|ar, a| a.quantity.times {ar << a.per_unit_buyout}; ar}
  end

  def overall_median_buyout
    overall_buyouts.median
  end

  def overall_mean_buyout
    overall_buyouts.mean
  end

private
  def self.extract_attributes_from_auction_hash(auction_hash)
    {
      :name           => auction_hash["n"],
      :item_id        => auction_hash["id"],
      :item_level     => auction_hash["ilvl"],
      :icon           => auction_hash["icon"],
      :required_level => auction_hash["req"],
      :quality_code   => auction_hash["qual"],
    }
  end
end
