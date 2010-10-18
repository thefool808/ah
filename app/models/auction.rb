class Auction < ActiveRecord::Base
  alias_attribute :first_seen_at, :created_at
  alias_attribute :last_seen_at,  :updated_at

  belongs_to :item

  def self.find_or_create_from_auction_hash(auction_hash)
    a = find_by_auction_id(auction_hash["auc"])
    if a
      a.touch
    else
      a = new(extract_attributes_from_auction_hash(auction_hash))
      a.save
    end
    return a
  end

private
  def self.extract_attributes_from_auction_hash(auction_hash)
    item = Item.find_or_create_from_auction_hash(auction_hash)
    {
      :seller_name         => auction_hash["seller"],
      :remaining_time_code => auction_hash["time"],
      :next_minimum_bid    => auction_hash["nbid"],
      :auction_id          => auction_hash["auc"],
      :buyout              => auction_hash["buy"],
      :charges             => auction_hash["charges"],
      :current_bid         => auction_hash["bid"],
      :quantity            => auction_hash["quan"],
      :per_unit_bid        => auction_hash["ppuBid"],
      :per_unit_buyout     => auction_hash["ppuBuy"],
      :item                => item
    }
  end
end
