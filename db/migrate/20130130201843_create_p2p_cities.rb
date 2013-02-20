class CreateP2pCities < ActiveRecord::Migration
  def change
    create_table :p2p_cities do |t|
      t.string :name
      t.string :latitude
      t.string :longitude

      t.timestamps
    end
  end
end
