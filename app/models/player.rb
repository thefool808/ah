class Player < ActiveRecord::Base
  has_many :auctions,
    :order => 'last_seen_scan_id DESC, (buyout / quantity) DESC, quantity DESC',
    :include => [:item, :last_seen_scan, :first_seen_scan]
end
