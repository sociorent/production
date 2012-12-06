class Image < ActiveRecord::Base
	attr_accessible :image, :image_url,:image_file_name
	attr_accessor :image_url

	before_validation :download_remote_image, :if => :image_url_provided?

  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>", :book => "130x160>" },
   :path => ":rails_root/public/system/:attachment/:class/:id/:style/:file_name.:extension",
    :url => "/system/:attachment/:class/:id/:style/:file_name.:extension"
  belongs_to :imageable, :polymorphic => true


  Paperclip.interpolates :file_name do |attachment, style|
    if attachment.instance.imageable_type=="Book"
      "#{attachment.instance.imageable.isbn13}"
    else
      "#{attachment.instance.imageable_type}-#{attachment.instance.id}"
    end
  end

  def image_url_provided?
    !self.image_url.blank?
  end

  def do_download_remote_image
    io = open(URI.parse(image_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
	  rescue 
    # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end

  def download_remote_image
    self.image = do_download_remote_image
    self.image_url = image_url
  end

  rails_admin do
		base do
			fields :image
		end
		visible false
	end
end
