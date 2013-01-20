class General < ActiveRecord::Base
  attr_accessible :general_images_attributes,:images_attributes, :intelligent_book, :welcome_mail_subject, :welcome_mail_content, :order_email_subject, :order_email_content, :address

  has_many :general_images
  has_many :images, :as => :imageable
  def intelligent_book_enum
    ['All friends', 'Friends in same College', 'Friends in same College and Stream']
  end

  accepts_nested_attributes_for :general_images, :images, :allow_destroy => true

end