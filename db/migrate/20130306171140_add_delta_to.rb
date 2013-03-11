class AddDeltaTo < ActiveRecord::Migration
	def change
		add_column :p2p_items ,:delta ,:boolean ,:default => true
		add_column :p2p_categories ,:delta ,:boolean ,:default => true
		add_column :p2p_products ,:delta ,:boolean ,:default => true
	end

end
