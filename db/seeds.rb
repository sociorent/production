# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
g = General.create(:welcome_mail_subject=>"Thank you for registering with us:Sociorent")
User.create(:email => "admin@admin.com", :password => "admin123", :name => "ADMIN", :is_admin => true)

# books
c1 = Category.create(:name => "Sports")
c2 = Category.create(:name => "Autobiography")
c3 = Category.create(:name => "Others")

p1 = Publisher.create(:name => "Penguin", :rental => 75)
p2 = Publisher.create(:name => "Wrox", :rental => 70)

#seeds for sliding logo images
# g.images.create(:image_url=>"http://1.bp.blogspot.com/-VmmofKydy14/TjpNGtViebI/AAAAAAAAA4E/bOqQkDjSa3o/s1600/HU%2BLogo%2B2nd%2BOption.jpg")
# g.images.create(:image_url=>"http://3.bp.blogspot.com/_CpC8QYlBkHM/TQhjafoWp9I/AAAAAAAAACM/7oiJbRJ11gs/s1600/Anna_university_logo.jpg")
# g.images.create(:image_url=>"http://blog.orgsync.com/wp-content/uploads/2011/08/louisiana-tech-university-logo.jpg")
# g.images.create(:image_url=>"http://blog.orgsync.com/wp-content/uploads/2011/08/louisiana-tech-university-logo.jpg")
# g.images.create(:image_url=>"http://blog.orgsync.com/wp-content/uploads/2011/08/shawnee-state-university-logo.gif")
# g.images.create(:image_url=>"http://blog.orgsync.com/wp-content/uploads/2011/08/washington-state-university-tri-cities-logo.gif")


# c2.books.create(:name => "vivek", :description => "this is an autobiography", :isbn10 => "123ad123", :author => "abc", :isbn13 => "12312321312", :binding =>"Hardcover", :publisher_id => p1.id, :published => "2009", :pages => 320, :price => 340, :strengths => "this is a sample strengths", :weaknesses => "this is sample weaknesses")
# c3.books.create(:name => "spiritual", :description => "god", :isbn10 => "1234343", :author => "abc", :isbn13 => "12312321312", :binding =>"Hardcover", :publisher_id => p1.id, :published => "2011/11", :pages => 320, :price => 340, :strengths => "this is a sample strengths", :weaknesses => "this is sample weaknesses")
# c1.books.create(:name => "golf", :description => "football is a nice game", :isbn10 => "123bh123", :author => "abc", :isbn13 => "12312321312", :binding =>"Hardcover", :publisher_id => p2.id, :published => "2009/11/30", :pages => 320, :price => 340, :strengths => "this is a sample strengths", :weaknesses => "this is sample weaknesses")
# c1.books.create(:name => "cricket", :description => "pakistan india t20", :isbn10 => "123bh123", :author => "abc", :isbn13 => "12312321312", :binding =>"Hardcover", :publisher_id => p2.id, :published => "2009", :pages => 320, :price => 340, :strengths => "this is a sample strengths", :weaknesses => "this is sample weaknesses")
# c1.books.create(:name => "sachin tendulkar", :description => "god of cricket", :isbn10 => "123bh123", :author => "abc", :isbn13 => "12312321312", :binding =>"Hardcover", :publisher_id => p1.id, :published => "2009", :pages => 320, :price => 340, :strengths => "this is a sample strengths", :weaknesses => "this is sample weaknesses")

# general

# g.general_images.create(:image_url => "http://www.doubledeclutch.com/wp-content/uploads/2011/10/10-porsche-posters-sm.jpg")
# g.general_images.create(:image_url => "http://fc09.deviantart.net/fs71/i/2012/209/b/d/books_and_magazines_design_linspire_solutions_by_linspiresolutions-d5905sx.jpg")
# g.general_images.create(:image_url => "http://cdn.shopify.com/s/files/1/0007/3442/files/New_Year_New_Diary_-_Greens.jpg?1290632676")
# g.general_images.create(:image_url => "http://www.pod-creative.com/_resources/images/projects/news/news_145_morrison_street_2.jpg")
# g.general_images.create(:image_url => "http://wildflowersphotos.com/blog/wp-content/uploads/2012/02/proutyBLOG1.jpg")
# g.general_images.create(:image_url => "http://fc02.deviantart.net/fs70/i/2012/103/9/2/bird_brain_books_1_3_by_rynnay-d4w2ae3.jpg")

# colleges
College.create(:name => "IIM")
College.create(:name => "VIT")

Stream.create(:name => "Mechanical")
Stream.create(:name => "Electrical")
Stream.create(:name => "Computer")
Stream.create(:name => "Biotech")

Semester.create(:name => "1")
Semester.create(:name => "2")
Semester.create(:name => "3")

# resources
# r = Resource.create(:name => "internships", :link => "internships")
# r.create_image(:image_url => "http://xiarch.com/testing/wp-content/uploads/2012/07/internship.jpg")



# c = Company.create(:name => "something", :offer_position => "developer", :offer_stipend => 20000)
# c.create_image(:image_url => "http://polarisleb.com/en/images/stories/company/TheCompany_office_2col.jpg")

# sms for signup and order
Sms.create(:sms_type=>"signup",:content=>"Thank you for registering with us")
Sms.create(:sms_type=>"order",:content=>"Thank you for ordering with us")
Bank.create(:name=>"SBI",:details=>"Account Details")

StaticPage.create(:page_name => "about_us", :page_title => "About us", :page_content => "", :is_active => true)
StaticPage.create(:page_name => "teams", :page_title => "Teams", :page_content => "teams", :is_active => true)
StaticPage.create(:page_name => "careers", :page_title => "Careers", :page_content => "careers", :is_active => true)
StaticPage.create(:page_name => "contact_us", :page_title => "Contant us", :page_content => "contact us", :is_active => true)
StaticPage.create(:page_name => "product_tour", :page_title => "Product Tour", :page_content => "product tour", :is_active => true)
StaticPage.create(:page_name => "features", :page_title => "Features", :page_content => "features", :is_active => true)
StaticPage.create(:page_name => "pricing", :page_title => "Pricing", :page_content => "pricing", :is_active => true)
StaticPage.create(:page_name => "colleges", :page_title => "Colleges", :page_content => "colleges", :is_active => true)
StaticPage.create(:page_name => "terms_of_use", :page_title => "Terms of use", :page_content => "terms of use", :is_active => true)
StaticPage.create(:page_name => "privacy_policy", :page_title => "Privacy policy", :page_content => "privacy policy", :is_active => true)
StaticPage.create(:page_name => "faq", :page_title => "FAQ", :page_content => "FAQ", :is_active => true)

load Rails.root.to_s + '/db/p2pseed.rb'

#