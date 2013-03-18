class RemoveColumnsFromItems < ActiveRecord::Migration
  def up
  	remove_column :p2p_items, :delivereddate
  	remove_column :p2p_items, :commision
  	remove_column :p2p_items, :paiddate
  end

  def down
  	add_column :p2p_items, :delivereddate,:date
  	add_column :p2p_items, :commision,:decimal, :precision=>10, :scale=>2
  	add_column :p2p_items, :paiddate,:date
  end
end
