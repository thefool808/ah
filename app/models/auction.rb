class Auction < ActiveRecord::Base
  belongs_to :item
  belongs_to :player
  belongs_to :first_seen_scan, :foreign_key => :first_seen_scan_id, :class_name => 'Scan'
  belongs_to :last_seen_scan,  :foreign_key => :last_seen_scan_id,  :class_name => 'Scan'

  # def self.import(auctions)
  #   auctions.each{|auction| find_or_create_from_auction_hash(auction) unless auction_hash["buy"].blank?}
  # end

  def self.import(auctions)
    # remove non-buyout auctions because they are gay
    aucs = auctions.dup.delete_if{|a| a["buy"].blank?}

    # find all the existing auctions
    auc_ids = aucs.collect{|a| a["auc"]}
    existing_aucs = where(:auction_id => auc_ids)
    existing_auc_ids = existing_aucs.collect{|a| a.auction_id}

    # update the last_seen_scan_id on all the existing auctions
    # sql = "UPDATE auctions SET last_seen_scan_id = ? WHERE auction_ids IN (#{existing_auc_ids.join(',')})"
    # ActiveRecord::Base.connection.execute(sql)

    # this should leave us with the ids of the new auctions
    new_auction_ids = auc_ids - existing_auc_ids
    new_auctions = aucs.delete_if{|a| !new_auction_ids.include?(a["auc"])}

    # get the item_ids
    new_auc_item_ids = new_auctions.collect{|a| a["id"]}
    existing_items = Item.where(:item_id => new_auc_item_ids)
    existing_item_ids = existing_items.collect{|i| i.item_id}

    new_auctions.each{|a|
      index = existing_item_ids.index(a["id"])
      if index === nil
        logger.info "Inserting Item #{a['n']}"
        a["item_id"] =  Item.create_from_auction_hash(a).id
      else
        a["item_id"] = existing_items[index].id
      end
    }

    # get the player ids
    new_auc_player_names = new_auctions.collect{|a| a["seller"]}
    existing_players = Player.where(:name => new_auc_player_names)
    existing_player_names = existing_players.collect{|p| p.name}

    new_auctions.each{|a|
      index = existing_player_names.index(a["seller"])
      if index === nil
        a["player_id"] = Player.create(:name => a["seller"]).id
      else
        a["player_id"] = existing_players[index].id
      end
    }

    # create the new auctions
    new_auctions.each{|a| create_from_auction_hash(a)}
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
    {
      :auction_id          => auction_hash["auc"],
      :buyout              => auction_hash["buy"],
      :quantity            => auction_hash["quan"],
      :player_id           => auction_hash["player_id"],
      :item_id             => auction_hash["item_id"]
    }
  end
end
