class StaticPage < ActiveRecord::Base
  attr_accessible :page_name, :page_title, :page_content, :is_active
end
