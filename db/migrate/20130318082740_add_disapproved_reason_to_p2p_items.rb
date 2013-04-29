class AddDisapprovedReasonToP2pItems < ActiveRecord::Migration
  def change
  	add_column :p2p_items, :disapproved_reason, :string
  end
end
