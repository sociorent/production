class CreateP2pItemSpecs < ActiveRecord::Migration
  def change
    create_table :p2p_item_specs do |t|
      t.references :spec
      t.string :value
      t.references :item

      t.timestamps
    end
    add_index :p2p_item_specs, :spec_id
    add_index :p2p_item_specs, :item_id
  end
end
