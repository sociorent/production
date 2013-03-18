class AddShippingAddressToItemDeliveries < ActiveRecord::Migration
  def change
  	add_column :p2p_item_deliveries, :shipping_address, :text
  end
end
