class CreateP2pUsers < ActiveRecord::Migration
  def change
    create_table :p2p_users do |t|
      t.references :user
      t.boolean :mobileverified ,:default => false

      t.timestamps
    end
    add_index :p2p_users, :user_id
  end
end
