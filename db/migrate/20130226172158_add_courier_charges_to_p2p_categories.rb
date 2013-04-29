class AddCourierChargesToP2pCategories < ActiveRecord::Migration
  def change
    add_column :p2p_categories, :courier_charge, :decimal ,:scale => 2 ,:precision => 3 ,:default => 0
  end
end
