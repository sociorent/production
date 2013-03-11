class CreateP2pMessages < ActiveRecord::Migration
  def change
    create_table :p2p_messages do |t|
      t.integer :sender
      t.integer :receiver
      t.string :item_id
      t.text :message
      t.datetime :readdatetime
      t.integer :messagetype, :default => 0

      t.timestamps
    end
  end
end
