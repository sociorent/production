class AddPayColumnsToP2pItems < ActiveRecord::Migration
  def change
    add_column :p2p_items, :payinfo, :string
    add_column :p2p_items, :commision, :decimal ,:scale => 2 ,:precision => 3
  end
end
