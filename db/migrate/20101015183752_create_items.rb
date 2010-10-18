class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :item_id
      t.string  :name
      t.integer :item_level
      t.string  :icon
      t.integer :required_level
      t.integer :quality_code
    end
    add_index :items, :item_id, :unique => true
    add_index :items, :name
  end

  def self.down
    drop_table :items
  end
end
