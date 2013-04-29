#todo check approving and not approving conditions...
# must not be sold,, must be finished..

#spec which are for notapproved and not done must not appear

class P2p::Item < ActiveRecord::Base


  belongs_to :product
  belongs_to :user
  belongs_to :city
  has_many :specs ,:class_name => "P2p::ItemSpec"

  has_many :messages ,:class_name => 'P2p::Message'
  has_one :itemlookup, :class_name=>"P2p::Itemlookup"

  has_one :category ,:through => :product

  has_many :images ,:class_name => 'P2p::Image'

  has_many :item_deliveries, :foreign_key=>'p2p_item_id'

  #has_many :bought_item , :through => :item_deliveries ,:class_name => 'P2p::Item' ,:foreign_key => 'item_id'

  attr_accessible :approveddate, :disapproveddate , :delivereddate, :desc, :paiddate, :paytype, :reqCount, :solddate, :title, :viewcount, :price ,:img,:condition, :deletedate , :payinfo,:commision, :disapproved_reason , :city_id , :totalcount , :soldcount



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

  scope :sold , where('soldcount > 0')

  scope :notsold , where('soldcount = 0')
  scope :active_items,  where('approveddate is not null and disapproveddate is null and (totalcount - soldcount) > 0')

  # listing the unsold ,not deleted and approved items
  scope :listing_items_by_location, lambda { |location|
    apnd_qry =""
    if location !="" and !location.nil?
      apnd_qry = "and (city_id = #{location} or (paytype=1 and payinfo like '%,1' ))"
    end
    where("( (totalcount - soldcount) > 0 ) and approveddate is not null and deletedate is null  and ((totalcount - soldcount) > 0 ) #{apnd_qry}").order("reqCount , viewcount")
  }

 define_index do

    #where ('deletedate is not null and paytype is not null and solddate is null')
    where ('deletedate is null and paytype is not null and ((totalcount - soldcount)>0)  ')
    indexes :title
    indexes :created_at, :sortable => true

#    set_property :delta =>true

  end

  def availablecount
    return self.totalcount - self.soldcount
  end

  before_save do
    self.soldcount = 0 if self.new_record?
  end

  after_update :update_changed_history

  after_create :new_item_created

  def update_changed_history

    admin = P2p::User.find_by_user_id(User.find_by_is_admin(1).id)

    changed_column =""

    self.changes.each do |column,value|

        next if ['approveddate','disapproveddate','solddate','deletedate','updated_at','viewcount','reqCount','disapproved_reason','soldcount'].include?(column)
        next if column =='paytype' or value[0] == value[1]

        P2p::ItemHistory.create(:approved => false , :columnname => column , :newvalue => value[1] ,:oldvalue =>  value[0] ,:item_id => self.id ,:created_at => self.updated_at )
    end

    self.images.each do |img|
      if img.updated_at.to_s == self.updated_at.to_s
       P2p::ItemHistory.create(:approved => false , :columnname => 'Image' , :newvalue => 'New Image' ,:oldvalue =>  'Old Image' ,:item_id => self.id ,:created_at => self.updated_at )
      end
    end

    self.itemhistories.where(:created_at => self.updated_at).each do |itemhistory|
      changed_column += "<li> #{itemhistory.columnname} from #{itemhistory.oldvalue} <b>-></b> #{itemhistory.newvalue}"
    end

    unless changed_column.empty?

      self.update_column(:approveddate,nil)

        begin
          PrivatePub.publish_to("/user_#{self.user.id}", 'Your changes have been sent to admin for approval' )
          PrivatePub.publish_to("/user_#{admin.id}", "#{self.user.user.name} has changed the data in <a href='#{URI.encode("/street/#{self.category.name.gsub(/[^0-9A-Za-z]/, '')}/#{self.category.id}/#{self.product.name.gsub(/[^0-9A-Za-z]/, '')}/#{self.product.id}/#{self.title.gsub(/[^0-9A-Za-z]/, '')}/#{self.id}/")}'>#{self.title}</a> listing and is waiting for your approval." )
        rescue

        end

        admin.sent_messages.create({:receiver_id => admin.id,
                                                  :message => "This is an auto generated system message. #{self.user.user.name}  has changed <a href='#{URI.encode("/street/#{self.category.name.gsub(/[^0-9A-Za-z]/, '')}/#{self.category.id}/#{self.product.name.gsub(/[^0-9A-Za-z]/, '')}/#{self.product.id}/#{self.title.gsub(/[^0-9A-Za-z]/, '')}/#{self.id}/")}'> #{self.title}</a> listing and is kept under your verification The changes are <br/>#{changed_column} <br/> Please review them. - System",
                                                  :messagetype => 5,
                                                  :sender_id => admin.id,
                                                  :sender_status => 2,
                                                  :receiver_status => 0,
                                                  :parent_id => 0
                                  });


        admin.sent_messages.create({:receiver_id => self.user.id ,
                                                  :message => "Your listing is under validation and you'll get a message <br> on the status of the item in a couple of hours. <br>This is a system generated message and you need not reply to this.<br><br>Thank you.<br>Sincerly,<br>Sociorent Street Team.",
                                                  :messagetype => 5,
                                                  :sender_id => admin.id,
                                                  :sender_status => 2,
                                                  :receiver_status => 0,
                                                  :parent_id => 0
                                                  });

    end
   # return true
  end

  def new_item_created
    admin = P2p::User.find_by_user_id(User.find_by_is_admin(1).id)

    message_notification = "
         $('#notificationcontainer').notify('create', 'new_item_notification', {
              title: '#{self.title}',
              msg: 'Your new listing has been sent to verification and will be approved quite soon'
          });

        if (oInboxTable){
            oInboxTable.fnDraw();
        }

        if (oSentBoxTable){
            oSentBoxTable.fnDraw();
        }
          if (oDeleteBoxTable){
            oDeleteBoxTable.fnDraw();
        }
"


    admin_message_notification = "
         $('#notificationcontainer').notify('create',  {
              title: 'New Listing waiting for approval ',
              text: '#{self.user.user.name}  has listed #{self.title} , and is waiting for your approval '
          });
      "

      begin
        PrivatePub.publish_to("/user_#{self.user.id}", message_notification )
        PrivatePub.publish_to("/user_1", admin_message_notification )
      rescue
      end

    admin.sent_messages.create({:receiver_id => self.user.id ,
                                              :message => "Thank you for listing an item in Sociorent Street. Your listing is under validation and you'll get a message <br> on the status of the item in a couple of hours.<br>This is a system generated message and you need not reply to this.<br><br>Thank you.<br><br>Sincerly,<br>Sociorent Street Team.",
                                              :messagetype => 5,
                                              :sender_id => admin.id,
                                              :sender_status => 2,
                                              :receiver_status => 0,
                                              :parent_id => 0
                                              });
    prod_url = URI.encode("/street/#{self.category.name.gsub(/[^0-9A-Za-z]/, '')}/#{self.category.id}/#{self.product.name.gsub(/[^0-9A-Za-z]/, '')}/#{self.product.id}/#{self.title.gsub(/[^0-9A-Za-z]/, '')}/#{self.id}/")

    admin.sent_messages.create({:receiver_id => admin.id,
                                              :message => "This is an auto generated system message. #{self.user.user.name} (#{self.user.user.email}) has listed a new item #{(self.totalcount == 1) ? '' : self.totalcount  } and is waiting for your verification. Listing link - <a href='#{prod_url}'>#{self.title}</a>. <br/> Thank you.. <br/> Sincerly, <br/> Developers",
                                              :messagetype => 5,
                                              :sender_id => admin.id,
                                              :sender_status => 2,
                                              :receiver_status => 0,
                                              :parent_id => 0
                                              });


    #send message to all fav users

    fav_users = P2p::Favourite.find_all_by_fav_id(self.user.id) || []

    fav_users.each do |fav|

        admin.sent_messages.create({:receiver_id => fav.p2puser.id,
                                                  :message => "This is an auto generated system message. Your favourite user #{self.user.user.name} has listed a new item. <a href='#{prod_url}'>#{self.title}</a> Give it a check. <br/> Thank you.. <br/> Sincerly, <br/> Admin",
                                                  :messagetype => 5,
                                                  :sender_id => admin.id,
                                                  :sender_status => 2,
                                                  :receiver_status => 0,
                                                  :parent_id => 0
                                                  });

    end

    return true
  end


  def get_image(count = 1, type=:view)
    res=[]


      img = self.images

      if type == :original
        img.each do |image|
          if image.process_status < 2
            res.push ({:url => image.img.url , :id => image.id.to_s })
          end
        end
        return res
      end

      if img.count ==0

        if type  == :view
          res.push({:url => "/assets/p2p/noimage_view.jpg" ,:id => 0})
        elsif type == :thumb
          res.push({:url => "/assets/p2p/noimage_thumb.jpg" ,:id => 0})
        elsif type == :search
          res.push({:url => "/assets/p2p/noimage_search.jpg" ,:id => 0})
        elsif type == :full
          res.push({:url => "/assets/p2p/noimage_view.jpg" ,:id => 0})
        end
        return res
      end

      if count == 1
        if img.first.process_status < 2

          if type  == :view
            res.push({:url => "/assets/p2p/approve_view.gif" ,:id => 0})
          elsif type == :thumb
            res.push({:url => "/assets/p2p/approve_thumb.gif" ,:id => 0})
          elsif type == :search
            res.push({:url => "/assets/p2p/approve_search.gif" ,:id => 0})
          elsif type == :full
            res.push({:url => "/assets/p2p/approve_view.gif" ,:id => 0})
          end
        end

        unless img.first.img?

            if type  == :view
              res.push({:url => "/assets/p2p/noimage_view.jpg" ,:id => 0})
            elsif type == :thumb
              res.push({:url => "/assets/p2p/noimage_thumb.jpg" ,:id => 0})
            elsif type == :search
              res.push({:url => "/assets/p2p/noimage_search.jpg" ,:id => 0})
            elsif type == :full
              res.push({:url => "/assets/p2p/noimage_view.jpg" ,:id => 0})
            end
        end

        res.push ({:url => img.first.img.url(type) , :id => img.first.id.to_s })
      else
        img.each do |img|

              if img.process_status < 2
                  if type  == :view
                    res.push({:url => "/assets/p2p/approve_view.gif" ,:id => 0})
                  elsif type == :thumb
                    res.push({:url => "/assets/p2p/approve_thumb.gif" ,:id => 0})
                  elsif type == :search
                    res.push({:url => "/assets/p2p/approve_search.gif" ,:id => 0})
                  elsif type == :full
                    res.push({:url => "/assets/p2p/approve_view.gif" ,:id => 0})
                  end
               next
              end
          unless img.img?

            if type  == :view
              res.push({:url => "/assets/p2p/noimage_view.jpg" ,:id => 0})
              next
            elsif type == :thumb
              res.push({:url => "/assets/p2p/noimage_thumb.jpg" ,:id => 0})
              next
            elsif type == :search
              res.push({:url => "/assets/p2p/noimage_search.jpg" ,:id => 0})
              next
            elsif type == :full
              res.push({:url => "/assets/p2p/noimage_view.jpg" ,:id => 0})
              next
            end
          end
          res.push ({:url => img.img.url(type) , :id => img.id.to_s })

        end
    end

    if res.count == 0 and type != :original
      if type  == :view
        res.push({:url => "/assets/p2p/noimage_view.jpg" ,:id => 0})
      elsif type == :thumb
        res.push({:url => "/assets/p2p/noimage_thumb.jpg" ,:id => 0})
      elsif type == :search
        res.push({:url => "/assets/p2p/noimage_search.jpg" ,:id => 0})
      elsif type == :full
        res.push({:url => "/assets/p2p/noimage_view.jpg" ,:id => 0})
      end

    end
    return res
end

  def paytype_text

    if self.paytype == 1
      return "Send by Courier"
    elsif self.paytype == 2
      return "Pay Directly"
    elsif self.paytype == 3
      return "Send by Sociorent"
    end

  end

  def is_valid_data?
    condition = ['Brand New','Like New','Good Conditon','Used']
    result = true
    #result = false if /^\d+\.?\d*$/.match(self.price) == nil
    result = false if self.price == 0
    find = false
    condition.each do |cond|
      if cond.downcase == self.condition.downcase()
        self.condition = cond.titleize()
        find = true
        break
      end
    end
    result = find
    result = false if self.city.nil?
    result
  end
end
