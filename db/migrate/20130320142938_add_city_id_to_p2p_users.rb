class AddCityIdToP2pUsers < ActiveRecord::Migration
  def change
  	add_column :p2p_users ,:city_id, :integer
  	add_index  :p2p_users ,:city_id
  end
end
