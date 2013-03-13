class AddFilterShowToP2pSpecs < ActiveRecord::Migration
  def change
    add_column :p2p_specs, :show_filter, :boolean ,:default => false
  end
end
