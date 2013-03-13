class CreateP2pServicePincodes < ActiveRecord::Migration
  def change
    create_table :p2p_service_pincodes do |t|
      t.string :pincode

      t.timestamps
    end
  end
end
