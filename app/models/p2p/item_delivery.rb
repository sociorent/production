class P2p::ItemDelivery < ActiveRecord::Base
		belongs_to :item , :class_name=>"P2p::Item", :foreign_key=>'p2p_item_id'

		has_one :seller, :through => :item

		belongs_to :buyer ,:foreign_key => 'buyer' , :class_name => 'P2p::User'

   attr_accessible :txn_id,:courier_name, :tracking_no,:shipping_date, :shipping_charge,:delivery_date,:citrus_pay_id,:commission, :citrus_reason, :citrus_ref_no,:buyer , :p2p_status, :shipping_address 


   scope :paysucess , where("citrus_pay_id = 'SUCCESS' ")
   # p2p_status
   # 0 => normal
   # 1 => invalid transcations
   # 2 => waiting       means payment was sucessfule, and waiting for delivery and shipping
   # 3 => refunding
   # 4 transcation failed
   # 5 => user complete
   # 6 => sociorent complete
   # 7 => shipped
   # 8 => warning_sent
   # 9 => refunded


   def statustext
      if self.p2p_status == 2
         return 'Waiting for Shippment'
      elsif self.p2p_status == 0
         return 'Payment Intiaited, but not done'
      elsif self.p2p_status == 4
         return 'Payment was cancelled in gateway'
      elsif self.p2p_status == 7 and !self.shipping_date.nil? and self.delivery_date.nil?
         return 'Item shipped'
      elsif self.p2p_status == 7 and !self.shipping_date.nil? and !self.delivery_date.nil?
         return 'Item Delivered'
      end
   end
end
