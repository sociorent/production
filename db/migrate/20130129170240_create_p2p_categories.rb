class CreateP2pCategories < ActiveRecord::Migration
  def change
    create_table :p2p_categories do |t|
      t.string :name
      t.references :category

      t.timestamps
    end

    add_index :p2p_categories , :category_id
  end
end
