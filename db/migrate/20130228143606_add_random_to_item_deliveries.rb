class AddRandomToItemDeliveries < ActiveRecord::Migration
	def change
		add_column :p2p_item_deliveries,:txn_id,:string
		add_column :p2p_item_deliveries,:citrus_reason,:string
		add_column :p2p_item_deliveries, :citrus_ref_no, :string
	end
end
