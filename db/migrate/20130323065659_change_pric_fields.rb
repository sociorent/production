class ChangePricFields < ActiveRecord::Migration
  def up
  	P2p::Item.update_all("price=CEIL(price)")
  	P2p::Category.update_all("courier_charge = CEIL(courier_charge)")
  	change_column :p2p_items, :price, :integer
  	change_column :p2p_categories, :courier_charge, :integer
  end

  def down
  	change_column :p2p_items, :price, :float
  	change_column :p2p_categories, :courier_charge, :precision=>3,:scale=>2
  end
end
