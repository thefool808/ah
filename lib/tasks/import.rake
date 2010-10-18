namespace :import do
  task(:all => :environment) do
    desc "Imports all current auctions"
    ah = AuctionHouse.new
    ah.login!
    ah.search(AuctionHouseQuery.everything)
  end
end
