require 'open-uri'

class P2p::Image < ActiveRecord::Base
  # attr_accessible :title, :body

  attr_accessible :img
  has_attached_file :img , :styles => { :view => "290X290", :thumb => "50X50#" ,:search => "110X155#" ,:full => "640X480" },
  					:default_url => '/assets/noimage.jpg'

  belongs_to :item

  validates :img, :attachment_presence => true

  def picture_from_url(url)
    self.img = open(url)
  end
end
