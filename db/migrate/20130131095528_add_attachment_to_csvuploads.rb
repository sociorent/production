class AddAttachmentToCsvuploads < ActiveRecord::Migration
   def self.up
   	remove_column :csvuploads, :csv
    change_table :csvuploads do |t|
      t.has_attached_file :csv
    end

  end

  def self.down
    drop_attached_file :csvuploads, :csv
  end
end
