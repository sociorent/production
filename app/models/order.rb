class Order < ActiveRecord::Base
  attr_accessible :random, :total, :rental_total, :order_type, :payment_done, :deposit_total,:gharpay_id, :accept_terms_of_use,:citruspay_response,:COD_mobile, :status,:bank_id
  has_many :book_orders, :dependent => :destroy
  has_many :books, :through => :book_orders

  

  belongs_to :bank
  belongs_to :user

  accepts_nested_attributes_for :bank

  scope :All
  scope :New, (where :status => 0 )
  scope :Cancelled, (where :status => 4 )
  scope :Shipped, (where :status => 1)
  scope :Unshipped, (where :status => 2)
  scope :Approved, (where 'status in (1,2,5,7)' )
  scope :Partially_unshipped, (where "status in (3,6,7)")
  scope :Partially_shipped, (where "status in (3,5,7)")
  scope :Partially_cancelled, (where "status in (5,6,7)")
  accepts_nested_attributes_for :bank, :user
  before_create :on => :create do 
    self.status = 0
  end 


  after_create do |order|
  	unique = 0
  	until unique == 1
	  	r = Random.new
	  	random = r.rand(10000..999999)
	  	order_search_with_random = Order.where(:random => random).first
	  	if order_search_with_random.nil?
	  		unique = 1
	  		order.update_attributes(:random => random)
	  	end
	  end
  end

  def order_type_enum
    ['cash', 'cheque', 'gharpay']
  end

  def order_status(cur_status = self.status.to_i)
  #contants for order status

     state = { 
      0 => 'New' ,
      1 => 'Fully Shipped' ,
      2 => 'Fully Unshipped' ,
      3 => 'Partially Shipped and Unshipped' ,
      4 => 'Fully Cancelled',
      5 => 'Partially Cancelled and Partially Shipped',
      6 => 'Partially Cancelled and Partially Unshipped',
      7 => 'Partially Cancelled and Partially Unshipped and Partially Shipped',
      8 => 'Approved' 
    }
    
    state[cur_status]
  end


end
