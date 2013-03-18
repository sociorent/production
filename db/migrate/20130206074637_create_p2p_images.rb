class CreateP2pImages < ActiveRecord::Migration
  def change
    create_table :p2p_images do |t|
      t.references :item
      t.timestamps
    end

    add_index :p2p_images , :item_id
    add_attachment :p2p_images, :img

  end
end
