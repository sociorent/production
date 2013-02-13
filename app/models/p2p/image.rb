class P2p::Image < ActiveRecord::Base
  # attr_accessible :title, :body

  attr_accessible :img
  has_attached_file :img , :styles => { :view => "320X240", :thumb => "57X57" ,:search => "135X135" ,:full => "640X480" },
  					:default_url => '/assets/noimage.jpg'

  belongs_to :item

  validates :img, :attachment_presence => true 

end
