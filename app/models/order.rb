class Order < ActiveRecord::Base
  attr_accessible :random, :total, :rental_total, :order_type, :payment_done, :deposit_total,:gharpay_id, :accept_terms_of_use,:citruspay_response,:COD_mobile

  has_many :book_orders, :dependent => :destroy
  has_many :books, :through => :book_orders
  belongs_to :bank
  has_many :shippings
  belongs_to :user
  belongs_to :college

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
end