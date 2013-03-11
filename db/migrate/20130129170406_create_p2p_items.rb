class CreateP2pItems < ActiveRecord::Migration
  def change
    create_table :p2p_items do |t|
      t.references :product
      t.references :user
      t.string :title 
      t.text :desc
      t.integer :paytype  ,:default => null
      t.datetime :solddate ,:default => null
      t.datetime :paiddate ,:default => null
      t.datetime :delivereddate ,:default => null
      t.boolean :approveddate ,:default => null
      t.integer :viewcount ,:default => 0
      t.integer :reqCount,:default => 0
      t.float :price 

      t.references :city

      t.timestamps
    end
    add_index :p2p_items, :product_id
    add_index :p2p_items, :user_id
    add_index :p2p_items, :city_id

  end
end
