class AddMultiToItems < ActiveRecord::Migration
  def up
  	add_column :p2p_items , :totalcount ,:integer
  	add_column :p2p_items , :soldcount ,:integer

  	#change tht iem
  	P2p::Item.unscoped.all.each do |item|
  		item.totalcount = 1 

  		item.soldcount  = ((item.solddate.nil?) ? 0 : 1)
  		
  		item.save
  	end

  end
end
