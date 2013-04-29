class CreateP2pItemlookups < ActiveRecord::Migration
  def change
    create_table :p2p_itemlookups do |t|
    	t.references :item
    	t.integer :view_count
      t.timestamps
    end
  end
end
