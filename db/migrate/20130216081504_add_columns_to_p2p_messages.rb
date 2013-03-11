class AddColumnsToP2pMessages < ActiveRecord::Migration

  def change
	add_column :p2p_messages , :parent_id ,:integer

  	add_index :p2p_messages , :sender_id
  	add_index :p2p_messages , :receiver_id
	add_index :p2p_messages , :parent_id

  add_column :p2p_messages, :receiver_status, :string
  end

end
