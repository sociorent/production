class ChangeApproveddateInP2pItems < ActiveRecord::Migration

  def change
  	remove_column :p2p_items , :approveddate 
  	add_column :p2p_items , :approveddate ,:datetime
  end


end
