class CreateP2pCredits < ActiveRecord::Migration
  def change
    create_table :p2p_credits do |t|
      t.references :user
      t.integer :type , :default => 1
      t.integer :totalCredits
      t.integer :available 

      t.timestamps
    end
    add_index :p2p_credits, :user_id
  end
end
