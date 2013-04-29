class AddAddressToP2pUsers < ActiveRecord::Migration
  def change
    add_column :p2p_users, :address, :text
  end
end
