class CreateP2pSpec < ActiveRecord::Migration
  def change
    create_table :p2p_specs do |t|
      t.string :name
      t.integer :display_type, :default => 1
      t.integer :parent_id
      t.references :category

      t.timestamps
    end

    add_index :p2p_specs, :category_id
  end
end
