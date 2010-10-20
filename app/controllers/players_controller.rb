class PlayersController < ApplicationController
  def show
    @player = Player.find(params[:id], :include => {:auctions => [:last_seen_scan, :first_seen_scan, :item]})
  end
end
