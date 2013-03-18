class AddReasonToP2pFailedCsvs < ActiveRecord::Migration
  def change
    add_column :p2p_failed_csvs, :reason, :string
    add_column :p2p_failed_csvs, :category_id, :integer

    add_index :p2p_failed_csvs ,:category_id
  end
end
