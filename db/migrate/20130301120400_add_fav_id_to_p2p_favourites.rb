class AddFavIdToP2pFavourites < ActiveRecord::Migration
  def change
    add_column :p2p_favourites, :fav_id, :integer

    add_index :p2p_favourites ,:fav_id
  end
end
