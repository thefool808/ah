class Item < ActiveRecord::Base
  has_many :auctions

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
