class Auction < ActiveRecord::Base
  belongs_to :item
  belongs_to :player
  belongs_to :first_seen_scan, :foreign_key => :first_seen_scan_id, :class_name => 'Scan'
  belongs_to :last_seen_scan,  :foreign_key => :last_seen_scan_id,  :class_name => 'Scan'

  def self.import(auctions)
    auctions.each{|auction| find_or_create_from_auction_hash(auction) unless auction_hash["buy"].blank?}
  end

  def self.import(auctions)
    aucs = auctions.dup.delete_if{|a| a["buy"].blank?}
    auc_ids = aucs.collect{|a| a["auc"]}
    existing_aucs = where(:auction_id => auc_ids)
    existing_auc_ids = existing_aucs.collect{|a| a.auction_id}
    new_auction_ids = auc_ids - existing_auc_ids
    aucs.each{|a| create_from_auction_hash(a) if new_auction_ids.include?(a["auc"])}
  end

  def self.find_or_create_from_auction_hash(auction_hash)
    a = find_by_auction_id(auction_hash["auc"])
    if a && AuctionHouse.current_scan
      a.update_attribute(:last_seen_scan_id, AuctionHouse.current_scan.id)
    elsif !a
      a = create_from_auction_hash(auction_hash)
    end
    return a
  end

  def self.create_from_auction_hash(auction_hash)
    a = new(extract_attributes_from_auction_hash(auction_hash))
    if AuctionHouse.current_scan
      a.first_seen_scan_id = AuctionHouse.current_scan.id
      a.last_seen_scan_id = AuctionHouse.current_scan.id
    end
    a.save
    return a
  end

  def per_unit_buyout
    self.buyout / self.quantity
  end

private
  def self.extract_attributes_from_auction_hash(auction_hash)
    item = Item.find_or_create_from_auction_hash(auction_hash)
    player = Player.find_or_create_by_name(auction_hash["seller"])
    {
      :auction_id          => auction_hash["auc"],
      :buyout              => auction_hash["buy"],
      :quantity            => auction_hash["quan"],
      :player_id           => player.id,
      :item_id             => item.id
    }
  end
end
