class AddMobileToP2pUsers < ActiveRecord::Migration
  def change
  	add_column :p2p_users, :mobile_number, :string
  end
end
