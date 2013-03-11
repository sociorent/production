class CreateP2pFailedCsvs < ActiveRecord::Migration
  def change
    create_table :p2p_failed_csvs do |t|
    	t.text :csv_data
    	t.references :vendor_upload
      t.timestamps
    end
	end


end
