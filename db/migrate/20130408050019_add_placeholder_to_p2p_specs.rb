class AddPlaceholderToP2pSpecs < ActiveRecord::Migration
  def change
    add_column :p2p_specs, :placeholder, :string , :default => ""
  end
end
