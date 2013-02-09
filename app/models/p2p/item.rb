class P2p::Item < ActiveRecord::Base


  belongs_to :product
  belongs_to :user
  belongs_to :city
  has_many :specs ,:class_name => "P2p::ItemSpec"


  has_many :images ,:class_name => 'P2p::Image'

  attr_accessible :approvedflag, :delivereddate, :desc, :paiddate, :paytype, :reqCount, :solddate, :title, :viewcount, :price ,:img

  attr_accessor :img


  default_scope where('deletedate is null')

  scope :sold , where('solddate is not null')

  scope :notsold , where('solddate is null')
  
 define_index do
    indexes :title
    
    has created_at,updated_at
  end


  def get_image(count = 1 ,size = 1)
    res=[]


    if self.images.count == 0 
      res.push({:url => "/assets/noimage.jpg" ,:id => 0})
    else

      unless self.images.first.img.exists?
          res.push({:url => "/assets/noimage.jpg" ,:id => 0})
          return res
      end

      if count == 1  
        if size ==1 
            res.push  ({:url => self.images.first.img.url(:view) ,:id =>self.images.first.id.to_s })
        elsif size == 2 
            res.push  ({:url => self.images.first.img.url(:thumb) ,:id =>self.images.first.id.to_s })
        else
          res.push  ({:url => self.images.first.img.url ,:id =>self.images.first.id.to_s })
        end
      else

        self.images.each do |img|

          unless img.img.exists?
            res.push({:url => "/assets/noimage.jpg" ,:id => 0})
          end

          if size == 1 
            res.push  ({:url => img.img.url(:view) , :id => img.id.to_s })
          elsif size == 2 
            res.push  ({:url => img.img.url(:thumb) , :id => img.id.to_s })
          else
            res.push  ({:url => img.img.url , :id => img.id.to_s })
          end
        end
      end

    end

    res
  end

end