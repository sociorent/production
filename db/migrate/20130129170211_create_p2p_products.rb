class CreateP2pProducts < ActiveRecord::Migration
  def change
    create_table :p2p_products do |t|
      t.string :name
      t.references :category

      t.timestamps
    end

    add_index :p2p_products , :category_id 
  end
end
