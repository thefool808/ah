class ItemsController < ApplicationController
  def index; end

  def show
    @item = Item.find(params[:id])
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
    @items = Item.find(:all, :conditions => ['UPPER(name) LIKE ?', "#{params[:name].upcase}"])
    if @items.length == 0
      render :text => "no results"
    elsif @items.length == 1
      redirect_to item_url(@items.first)
    else
      render :list
    end
  end
end
