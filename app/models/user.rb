class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :name, :is_admin, :college_id, :mobile_number, :friends, :stream_id, :wishlist, :ambassador_id, :ambassador_manager_attributes, :image,:address,:unique_id, :token

  has_many :reviews, :dependent => :destroy
  has_one :cart, :dependent => :destroy

  has_many :requests, :dependent => :destroy
  has_many :orders, :dependent => :destroy
  has_many :books, :through => :orders

  belongs_to :college
  belongs_to :stream

  
  belongs_to :ambassador
  has_one :ambassador_manager, :class_name => "Ambassador", :foreign_key => "ambassador_manager_id"

  has_many :company_users
  has_many :companies, :through => :company_users

  accepts_nested_attributes_for :ambassador_manager, :allow_destroy => true

  after_create do |user|
    user.create_cart()
    UserMailer.delay.welcome_email(user)
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    resp = {}
	  user = User.where(:provider => auth.provider, :uid => auth.uid).first
    resp[:new_user] = false
	  unless user
      resp[:new_user] = true
	    user = User.create(name:auth.extra.raw_info.name,
	                         provider:auth.provider,
	                         uid:auth.uid,
	                         email:auth.info.email,
	                         password:Devise.friendly_token[0,20],
                           image:auth.info.image
	                         )
	  end
    resp[:user] = user.id
	  resp.to_json()
	end

	def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
end