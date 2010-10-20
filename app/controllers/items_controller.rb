class ItemsController < ApplicationController
  def index; end

  def show
    @item = Item.find(
      params[:id],
      :include => {:auctions => [:last_seen_scan, :first_seen_scan, :player]}
    )
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(params[:item])
    if @item.save
      redirect_to item_url(@item)
    else
      render :new
    end
  end

  def search
    @condish = ['name LIKE ?', "#{params[:name]}"]
    @items = Item.find(:all, :conditions => @condish)
    if @items.length == 0
      render :no_results
    elsif @items.length == 1
      redirect_to item_url(@items.first)
    else
      render :list
    end
  end
end
