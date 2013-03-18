class AddDisapproveDateToP2pItems < ActiveRecord::Migration
  def change
    add_column :p2p_items, :disapproveddate, :datetime
  end
end
