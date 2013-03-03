#todo check approving and not approving conditions...
# must not be sold,, must be finished..

#spec which are for notapproved and not done must not appear

class P2p::Item < ActiveRecord::Base


  belongs_to :product
  belongs_to :user
  belongs_to :city
  has_many :specs ,:class_name => "P2p::ItemSpec"

  has_many :messages ,:class_name => 'P2p::Message'

  has_one :category ,:through => :product

  has_many :images ,:class_name => 'P2p::Image'

  has_many :item_deliveries, :foreign_key=>'p2p_item_id'
  attr_accessible :approveddate, :disapproveddate , :delivereddate, :desc, :paiddate, :paytype, :reqCount, :solddate, :title, :viewcount, :price ,:img,:condition, :deletedate , :payinfo,:commision



  #payinfo has the follwing structure for courier service
  # days to dispathc , allover india

  # paytype
  # 1- courier
  # 2- direct
  # 3 -online

  attr_accessor :img

  has_many :itemhistories , :class_name => 'P2p::ItemHistory'

  # validates :title ,:uniqueness => true  if :new_record?

  default_scope where("deletedate is null and paytype is not null"  )



  scope :by_location_or_allover , lambda { |location|
    if location !=""
      where ("(city_id = #{location} or (paytype=1 and payinfo like '%,1' ))")
    else
      return
    end

  }

  scope :approved , where('approveddate is not null')
  scope :notapproved , where('approveddate is null')
  scope :disapproved , where('disapproveddate is  not null')
  scope :notdisapproved , where('disapproveddate is  null')

  scope :waiting , where('approveddate is null and disapproveddate is null')

  scope :deleted , where('deletedate is not  null')
  scope :notdeleted , where('deletedate is null')

  scope :notfinished , where(' deletedate is null and paytype is null')

  scope :sold , where('solddate is not null')

  scope :notsold , where('solddate is null')

 define_index do

    #where ('deletedate is not null and paytype is not null and solddate is null')
    where ('deletedate is null and paytype is not null and solddate is null')
    indexes :title



  end


  before_save do
    self.desc = self.desc.strip
  end
  after_update :update_changed_history

  after_create :new_item_created

  def update_changed_history

    adminid = 2

    changed_column =""

    self.changes.each do |column,value|

      next if column == 'approveddate' or column == 'updated_at' or column =='viewcount' or column == 'reqCount'

      next if (column == 'paytype' or column =='payinfo' or column=='commision' ) and self.changes.has_key?(:paytype) and self.changes[:paytype][0] == nil

      self.itemhistories.create(:approved => false , :columnname => column , :newvalue => value[0] ,:oldvalue =>  value[1] )
      changed_column += "<li> #{column} from #{value[1]} -> #{value[0]}</li>"
    end


    self.itemhistories.where(:created_at => self.updated_at).each do |itemhistory|
      changed_column += "<li> #{itemhistory.columnname} from #{itemhistory.oldvalue} -> #{itemhistory.newvalue}"
    end

    unless changed_column.empty?

        #PrivatePub.publish_to("/user_#{self.user.id}", 'Your changes have been sent to admin for approval' )
        PrivatePub.publish_to("/user_1", "#{self.user.user.name} has changed the data in <a href='/p2p/#{self.category.name}/#{self.product.name}/#{self.title}'>#{self.title}</a> listing and is waiting for your approval." )



        P2p::User.find(1).sent_messages.create({:receiver_id => adminid,
                                                  :message => "This is an auto generated system message. #{self.user.user.name}  has changed <a href='/p2p/#{self.category.name}/#{self.product.name}/#{self.title}'>#{self.title}</a> listing and is kept under your verification The changes are <br/>#{changed_column} <br/> Please review them. - System",
                                                  :messagetype => 5,
                                                  :sender_id => adminid,
                                                  :sender_status => 2,
                                                  :receiver_status => 0,
                                                  :parent_id => 0
                                                  });


        P2p::User.find(1).sent_messages.create({:receiver_id => self.user.id ,
                                                  :message => "This is an auto generated system message. Your <a href='/p2p/#{self.category.name}/#{self.product.name}/#{self.title}'>#{self.title}</a> listing is kept under verification and will appear on the site with in 2hours. To send a message to admin just click reply and send your message. <br/> Thank you.. <br/> Sincerly, <br/> Admin - Sociorent",
                                                  :messagetype => 5,
                                                  :sender_id => adminid,
                                                  :sender_status => 2,
                                                  :receiver_status => 0,
                                                  :parent_id => 0
                                                  });

    end

  end

  def new_item_created
    adminid = 2

    message_notification = "
         $('#notificationcontainer').notify('create', 'new_item_notification', {
              title: '#{self.title}',
              msg: 'Your new listing has been sent to verification and will be approved quite soon'
          });

        if (oInboxTable){
            oInboxTable.fnDraw();
          }elseif (oSentBoxTable){
            oSentBoxTable.fnDraw();
          }elseif (oDeleteBoxTable){
            oDeleteBoxTable.fnDraw();
        }
"


    admin_message_notification = "
         $('#notificationcontainer').notify('create',  {
              title: 'New Listing waiting for approval ',
              text: '#{self.user.user.name}  has listed #{self.title} , and is waiting for your approval '
          });
      "

    PrivatePub.publish_to("/user_#{self.user.id}", message_notification )
    PrivatePub.publish_to("/user_1", admin_message_notification )

    P2p::User.find(1).sent_messages.create({:receiver_id => self.user.id ,
                                              :message => 'This is an auto generated system message. Your listing is kept under verification and will appear on the site with in 2hours. To send a message to me just click compose and send your message. <br/> Thank you.. <br/> Sincerly, <br/> Admin - Sociorent',
                                              :messagetype => 5,
                                              :sender_id => adminid,
                                              :sender_status => 2,
                                              :receiver_status => 0,
                                              :parent_id => 0
                                              });
    prod_url = URI.encode("/p2p/#{self.category.name}/#{self.product.name}/#{self.title}")

    P2p::User.find(1).sent_messages.create({:receiver_id => adminid,
                                              :message => "This is an auto generated system message. #{self.user.user.name} (#{self.user.user.email}) has listed a new item and is waiting for your verification. Listing link - <a href='#{prod_url}'>#{self.title}</a>. <br/> Thank you.. <br/> Sincerly, <br/> Developers",
                                              :messagetype => 5,
                                              :sender_id => adminid,
                                              :sender_status => 2,
                                              :receiver_status => 0,
                                              :parent_id => 0
                                              });



  end


  def get_image(count = 1, type=:view)
    res=[]


    if self.images.nil?
        if type  == :view
          res.push({:url => "/assets/p2p/noimage_view.jpg" ,:id => 0})
        elsif type == :thumb
          res.push({:url => "/assets/p2p/noimage_thumb.jpg1" ,:id => 0})
        elsif type == :search
          res.push({:url => "/assets/p2p/noimage_search.jpg" ,:id => 0})
        end
      return res
    end

    if self.images.count == 0
        if type  == :view
          res.push({:url => "/assets/p2p/noimage_view.jpg" ,:id => 0})
        elsif type == :thumb
          res.push({:url => "/assets/p2p/noimage_thumb.jpg2" ,:id => 0})
        elsif type == :search
          res.push({:url => "/assets/p2p/noimage_search.jpg" ,:id => 0})
        end

    else

      unless self.images.first.img.exists?
        if type  == :view
          res.push({:url => "/assets/p2p/noimage_view.jpg" ,:id => 0})
        elsif type == :thumb
          res.push({:url => "/assets/p2p/noimage_thumb.jpg3" ,:id => 0})
        elsif type == :search
          res.push({:url => "/assets/p2p/noimage_search.jpg" ,:id => 0})
        end

        return res
      end

      img = self.images

      if count == 1
        res.push ({:url => img.first.img.url(type) , :id => img.first.id.to_s })
      else
        img.each do |img|
          unless img.img.exists?

            if type  == :view
              res.push({:url => "/assets/p2p/noimage_view.jpg" ,:id => 0})
            elsif type == :thumb
              res.push({:url => "/assets/p2p/noimage_thumb.jpg4" ,:id => 0})
            elsif type == :search
              res.push({:url => "/assets/p2p/noimage_search.jpg" ,:id => 0})
            end

          end

          res.push ({:url => img.img.url(type) , :id => img.id.to_s })
        end
      end

      res
    end
  end




end
