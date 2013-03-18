class AddBuyerToP2pItemDeleveries < ActiveRecord::Migration
  def change
    add_column :p2p_item_deliveries, :buyer, :integer
    add_index :p2p_item_deliveries, :buyer
  end
end
