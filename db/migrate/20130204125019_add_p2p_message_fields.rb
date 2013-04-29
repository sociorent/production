class AddP2pMessageFields < ActiveRecord::Migration
  def change
  	add_column :p2p_messages , :sender_id ,:integer
  	add_column :p2p_messages , :receiver_id ,:integer
  	add_column :p2p_messages , :flag ,:string
  end

end
