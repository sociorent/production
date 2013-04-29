class AddShowCityToP2pCities < ActiveRecord::Migration
  def change
    add_column :p2p_cities, :show_city, :boolean ,:default => false
  end
end
