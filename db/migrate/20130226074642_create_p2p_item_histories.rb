class CreateP2pItemHistories < ActiveRecord::Migration
  def change
    create_table :p2p_item_histories do |t|
      t.references :item
      t.string :columnname
      t.string :oldvalue
      t.string :newvalue
      t.boolean :approved

      t.timestamps
    end
    add_index :p2p_item_histories, :item_id
  end
end
