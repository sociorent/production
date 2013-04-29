class AddProcessingStateToP2pImages < ActiveRecord::Migration
  def change
    add_column :p2p_images, :process_status, :integer ,:default => 0
    
    P2p::Image.update_all(:process_status => 2)
  end


end
