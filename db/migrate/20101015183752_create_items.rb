class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :item_id
      t.text    :name
      t.integer :item_level
      t.text    :icon
      t.integer :required_level
      t.integer :quality_code
      t.timestamps
    end
    add_index :items, :item_id, :unique => true
    add_index :items, :name
  end

  def self.down
    drop_table :items
  end
end
