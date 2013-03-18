class AddDeleteDateToP2pItems < ActiveRecord::Migration
  def change
    add_column :p2p_items, :deletedate, :datetime
  end
end
