class CreateP2pFavourites < ActiveRecord::Migration
  def change
    create_table :p2p_favourites do |t|
      t.references :user

      t.timestamps
    end
    add_index :p2p_favourites, :user_id
  end
end
