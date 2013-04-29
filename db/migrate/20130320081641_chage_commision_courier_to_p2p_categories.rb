class ChageCommisionCourierToP2pCategories < ActiveRecord::Migration
  def change
  	change_column :p2p_categories, :courier_charge, :decimal ,:scale => 2 ,:precision => 10 ,:default => 0
  	change_column :p2p_categories, :commission, :decimal ,:scale => 2 ,:precision => 10 ,:default => 0
  end
end
