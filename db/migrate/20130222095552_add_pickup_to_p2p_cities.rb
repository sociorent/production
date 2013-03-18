class AddPickupToP2pCities < ActiveRecord::Migration
  def change
    add_column :p2p_cities, :pickup, :integer ,:default => 0
  end
end
