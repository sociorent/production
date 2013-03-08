class CreateP2pVendorUploads < ActiveRecord::Migration
  def change
    create_table :p2p_vendor_uploads do |t|
				t.boolean :processed, :default=>false
				t.integer :category_id
				t.references :user
      t.timestamps
    end
    add_index :p2p_vendor_uploads, :category_id
    add_index :p2p_vendor_uploads, :user_id
    add_attachment :p2p_vendor_uploads, :upload_csv
  end
end
