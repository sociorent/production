class CreateP2pItemDeliveries < ActiveRecord::Migration
  def change
    create_table :p2p_item_deliveries do |t|
    	t.string :courier_name
    	t.string :tracking_no
    	t.string :shipping_charge
    	t.datetime :shipping_date
    	t.datetime :delivery_date
    	t.string :citrus_pay_id
    	t.decimal :commission, :precision=>10, :scale => 2
    	t.references :p2p_item


      t.timestamps
    end
    add_index :p2p_item_deliveries, :tracking_no
    add_index :p2p_item_deliveries, :p2p_item_id
  end
end
