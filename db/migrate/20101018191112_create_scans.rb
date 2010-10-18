class CreateScans < ActiveRecord::Migration
  def self.up
    create_table :scans do |t|
      t.integer  :auction_count
      t.datetime :started_at
      t.datetime :finished_at
    end
  end

  def self.down
    drop_table :scans
  end
end
