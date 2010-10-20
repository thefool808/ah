class AddNameIndexToPlayers < ActiveRecord::Migration
  def self.up
    add_index(:players, :name, :unique => true)
  end

  def self.down
    remove_index(:players, :name)
  end
end
