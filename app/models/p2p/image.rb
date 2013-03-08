require 'open-uri'

class P2p::Image < ActiveRecord::Base
  # attr_accessible :title, :body
	attr_accessor :image_url
  attr_accessible :img,:image_url
  has_attached_file :img , :styles => { :view => "290X290", :thumb => "50X50#" ,:search => "110X155#" ,:full => "640X480" },
  					:default_url => '/assets/noimage.jpg'

#	before_save :download_remote_image, :if => :image_url_provided?

  #paper clip infinte loop fior before validate

  belongs_to :item

  #validates :img, :attachment_presence => true

  def image_url_provided?
    !self.image_url.blank?
  end

  def download_remote_image
    self.img = open(self.image_url)
  end
end
