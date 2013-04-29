class AddSenderStatusToP2pMessage < ActiveRecord::Migration
  def change
    add_column :p2p_messages, :sender_status, :string
  end
end
