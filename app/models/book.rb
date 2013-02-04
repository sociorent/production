class Book < ActiveRecord::Base
  attr_protected []
  attr_accessor :book_image, :book_original, :published_date

  has_many :images, :as => :imageable
  has_many :reviews

  belongs_to :category
  belongs_to :publisher

  has_many :book_carts
  has_many :carts, :through => :book_carts

  has_many :book_orders
  has_many :orders, :through => :book_orders

  has_many :class_adoptions, :dependent => :destroy
  
  has_many :book_colleges
  has_many :colleges, :through => :book_colleges

  has_many :book_streams
  has_many :streams, :through => :book_streams

  has_many :book_semesters
  has_many :semesters, :through => :book_semesters

  accepts_nested_attributes_for :images, :class_adoptions, :reviews, :book_colleges, :book_streams, :book_semesters, :allow_destroy => true
  
  validates :isbn13, :uniqueness=>true
  validates :isbn13, :publisher_id,:presence=>true, :on => :create
  validates :isbn13, :publisher_id,:presence=>true, :on => :update
  
  after_create do |book|
    r = Random.new
    rank = r.rand(50..100)
    book.update_attributes(:rank => rank)
  end

  define_index do
  	indexes :name, :sortable => true
    indexes :author, :sortable => true
    indexes :isbn13
    indexes :isbn10

    
    set_property :min_infix_len => 3
    # set_property :delta =>true

  end

	def book_image
  	unless self.images.count == 0
      self.images.first.image(:original)
    else
      "/assets/no_book.jpeg"
    end
  end

  def book_original
    unless self.images.count == 0
      self.images.first.image(:original)
    else
      "/assets/no_book.jpeg"
    end
  end

  def published_date
    published = self.published
    date_json = ""
    if published
      published_date = published.gsub(" ","")
      published_date = published.gsub("/",",")
      if /^\d{4}\,\d{2}\,\d{2}$/.match published_date
        date = Date.strptime("{#{published_date}}", "{%Y,%m,%d}")
      elsif /^\d{4}\,\d{2}$/.match published_date
        date = Date.strptime("{#{published_date}}", "{%Y,%m}")
      elsif /^\d{4}$/.match published_date 
        date = Date.strptime("{#{published_date}}", "{%Y}")
      end
      date_json = date
    end
    date_json
  end

  def as_json(options = { })
  	h = super(options)
    # adding virtual attributes to the json
    h[:book_image] = book_image
    h[:book_original] = book_original
    h[:published_date] = published_date
    # returning the new json
    h
  end

  def rent
    rent = self.publisher.rental
    ((self.price.to_f/100)*rent).ceil
  end

end