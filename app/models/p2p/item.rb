class P2p::Item < ActiveRecord::Base


  belongs_to :product
  belongs_to :user
  belongs_to :city
  has_many :specs ,:class_name => "P2p::ItemSpec"
 
  has_one :category ,:through => :product

  has_many :images ,:class_name => 'P2p::Image'

  attr_accessible :approveddate, :delivereddate, :desc, :paiddate, :paytype, :reqCount, :solddate, :title, :viewcount, :price ,:img,:condition

  attr_accessor :img

  # validates :title ,:uniqueness => true  if :new_record?

  default_scope where('deletedate is null')

  scope :notapproved , where('approveddate is null')

  scope :sold , where('solddate is not null')

  scope :notsold , where('solddate is null')
  
 define_index do
    indexes :title
    
    has created_at,updated_at
  end


  def get_image(count = 1, type=:view)
    res=[]

    if self.images.count == 0 
      res.push({:url => "/assets/noimage.jpg" ,:id => 0})
    else

      unless self.images.first.img.exists?
        res.push({:url => "/assets/noimage.jpg" ,:id => 0})
        return res
      end

      img = self.images

      if count == 1  
        res.push ({:url => img.first.img.url(type) , :id => img.first.id.to_s })
      else
        img.each do |img|
          unless img.img.exists?
            res.push({:url => "/assets/noimage.jpg" ,:id => 0})
          end

          res.push ({:url => img.img.url(type) , :id => img.id.to_s })
        end
      end

      res
    end
  end

end
