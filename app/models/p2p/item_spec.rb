class P2p::ItemSpec < ActiveRecord::Base

  belongs_to :spec ,:class_name => 'P2p::Spec'
  belongs_to :item ,:class_name => 'P2p::Item'

  attr_accessible :value   ,:update_at ,:created_at, :spec_id

 #  before_destroy do
	# #puts self.inspect + "bafter delete"
	# self.item.itemhistories.create(:approved => false , :columnname => self.spec.name(self.spec.id) , :newvalue => "" ,:oldvalue =>  self.value ,:created_at => P2p::item_updated_at )
 #  end

  after_destroy do
  	self.item.itemhistory.create(:approved => false , :columnname => "#{self.spec.name}(#{self.spec.id})" , :newvalue => "" ,:oldvalue =>  self.value ,:created_at => self.updated_at )
  end

  after_save do

  	#self.item.itemhistories.create(:approved => false , :columnname => "#{self.spec.name} (#{self.spec.id})" , :newvalue => self.value ,:oldvalue =>  "" ,:created_at => self.created_at ) if :new_record?

  end

   after_update do
   	self.item.itemhistories.create(:approved => false , :columnname => "#{self.spec.name} (#{self.spec.id})" , :newvalue => self.value ,:oldvalue =>  self.value_was ,:created_at => self.updated_at )  if !(self.new_record?)
  end

end

