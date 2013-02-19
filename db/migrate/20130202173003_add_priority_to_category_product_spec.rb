class AddPriorityToCategoryProductSpec < ActiveRecord::Migration
  def change
  	add_column :p2p_categories , :priority ,:integer
  	add_column :p2p_specs , :priority ,:integer
  	add_column :p2p_products , :priority ,:integer
  end
end
