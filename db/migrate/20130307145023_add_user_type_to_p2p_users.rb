class AddUserTypeToP2pUsers < ActiveRecord::Migration
  def change
    add_column :p2p_users, :user_type, :integer ,:default => 0
  end
end
