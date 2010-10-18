namespace :import do
  task(:all => :environment) do
    desc "Imports all current auctions"
    AuctionHouse.import_all
  end
end
