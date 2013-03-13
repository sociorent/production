class AddP2pStatusToP2pItemDeliveries < ActiveRecord::Migration
  def change
    add_column :p2p_item_deliveries, :p2p_status, :integer ,:default => 0
  end
end
