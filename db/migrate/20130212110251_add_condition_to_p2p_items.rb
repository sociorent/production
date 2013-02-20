class AddConditionToP2pItems < ActiveRecord::Migration
  def change
    add_column :p2p_items, :condition, :string
  end
end
