class AuctionHouseQuery# < ActiveRecord::Base
  SortingParameters = [
    'rarity',     # epics first
    'name',       # alphabetical
    'level',      # required level, highest first
    'ilvl',       # item level, highest first
    'bid',        # stack bid, lowest first
    'buyout',     # stack buyout, lowest first
    'unitbid',    # price per unit, lowest first
    'unitbuyout', # price per unit, lowest first
    'time'        # time remaining, shortest first
  ]

  SearchParamters = [
    'filterId', # maps to ah categories (see below)
    'maxLvl',   # maximum level required  any valid character level
    'minLvl',   # minimum level required  any valid character level
    'qual',     # item quality  0=poor, 1=common, 2=uncommon, 3=rare, 4=epic
    'reverse',  # reverse the sort output true, false
    'sort',     # column to sort by rarity, quantity, level, time, buyout
    'n',        # name of item
    'id'        # id of item
  ]

  attr :parameters

  def initialize(params)
    @parameters = params
  end

  def self.everything
    parameters = {
      'pageSize' => '50',
      'sort' => 'buyout',
      'reverse' => 'true'
    }
    new(parameters)
  end

  def self.for_item(item)
    parameters = {
      'pageSize' => '200',
      'sort' => 'unitbuyout',
      'reverse' => 'false',
      'id' => item.item_id
    }
    new(parameters)
  end

  def to_s
    '?' + self.class.hash_to_param_string(self.parameters)
  end

private
  def self.hash_to_param_string(hsh)
    hsh.inject([]){|res,el| res << "#{URI.escape(el[0].to_s)}=#{URI.escape(el[1].to_s)}"; res}.join("&")
  end
end
