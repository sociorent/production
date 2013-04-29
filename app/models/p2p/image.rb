require 'open-uri'

class P2p::Image < ActiveRecord::Base
  # attr_accessible :title, :body
	attr_accessor :image_url ,:force_reporcess
  attr_accessible :img,:image_url
  has_attached_file :img , :styles => { :view => "290X290>", :thumb => "50X50>" ,:search => "110X155>" ,:full => "640X480>" },
    :storage => :s3,
    :bucket => 'sociorent_street',
    :s3_credentials => {
      :access_key_id => 'AKIAIYLZTHQ7DOFWICFA',
      :secret_access_key => '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'
   }

  before_post_process :process_only_on_approval

  def process_only_on_approval

    if (self.item.nil? or self.item.approveddate.nil? ) and self.force_reporcess != 1
      return false
    else
      return true
    end

  end

  before_save do
    if self.new_record? and (!self.item.nil?)
      self.created_at = self.item.updated_at
    end
  end

  def process_image
      self.force_reporcess = 1
      self.img.reprocess!
  end

#	before_save :download_remote_image, :if => :image_url_provided?

  #paper clip infinte loop fior before validate

  belongs_to :item


  # Paperclip.interpolates :file_name do |attachment, style|
  #    "#{attachment.instance.id}.jpg"
  # end


  #validates :img, :attachment_presence => true

  def image_url_provided?
    !self.image_url.blank?
  end

  def download_remote_image
    self.img = open(self.image_url)
  end
end
