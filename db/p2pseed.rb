
# load Rails.root.to_s + '/db/p2pseed.rb'

		
		user1 = User.find_by_email('admin@admin.com')
		adminuser = P2p::User.new
		adminuser.user = user1
		adminuser.user_type = 1
		adminuser.save

		user1 = User.find_by_email('sen@sen.com')
		user = P2p::User.new
		user.user = user1
		user.save


		# books

	cat = P2p::Category.create({:name => "Books"})
	
	cat.products.new({:name => "Fiction" })
	cat.products.new({:name => "Novel"})
	cat.products.new({:name => "Nonfiction"})
	cat.products.new({:name => "Biographies"})
	cat.products.new({:name => "Technology"})
	cat.products.new({:name => "Software"})
	cat.products.new({:name => "Self development"})
	cat.products.new({:name => "Comics"})



	cat.specs.new({:name => 'ISBN-13',:show_filter => false})
	cat.specs.new({:name => 'ISBN-10',:show_filter => false})
	cat.specs.new({:name => 'Page Count',:show_filter => false})
	cat.specs.new({:name => 'Author',:show_filter => false})
	cat.specs.new({:name => 'Edition',:show_filter => false})
	cat.specs.new({:name => 'Binding',:show_filter => false})
	cat.specs.new({:name => 'Published Year',:show_filter => false})

	cat.specs.new({:name => 'Publisher' ,:show_filter => true})
	
	cat.save

	# Mobiles
		cat = P2p::Category.create({:name => "Mobile"})
			
		cat.products.new({:name => "Nokia"})
		cat.products.new({:name => "Sony"})
		cat.products.new({:name => "Samsung"})
		cat.products.new({:name => "LG"})

		cat.specs.new({:name => 'Model' ,:show_filter => true})
		cat.specs.new({:name => 'OS' ,:show_filter => true})
		cat.specs.new({:name => 'Storage' ,:show_filter => true})
		cat.specs.new({:name => 'Camera' ,:show_filter => true})
		cat.specs.new({:name => 'Type' ,:show_filter => true})


		cat.specs.new({:name => 'Touch Screen' ,:show_filter => false})
		cat.specs.new({:name => 'SIM' ,:show_filter => false})
		cat.specs.new({:name => 'Form' ,:show_filter => false})
		cat.specs.new({:name => 'Operating Freq' ,:show_filter => false})
		cat.specs.new({:name => 'Java' ,:show_filter => false})
		cat.specs.new({:name => 'Processor' ,:show_filter => false})
		cat.specs.new({:name => 'Display Size' ,:show_filter => false})
		cat.specs.new({:name => 'Resolution' ,:show_filter => false})
		cat.specs.new({:name => 'Internal Storage' ,:show_filter => false})
		cat.specs.new({:name => 'Expandable Memory' ,:show_filter => false})
		cat.specs.new({:name => 'GPRS' ,:show_filter => false})
		cat.specs.new({:name => '3G' ,:show_filter => false})
		cat.specs.new({:name => 'EDGE' ,:show_filter => false})

		cat.save

		# Camera
		cat = P2p::Category.create({:name => "Camera"})

			cat.products.new({:name => "Sony"})
			cat.specs.new({:name => 'Mega pixel' ,:show_filter => true})
			cat.specs.new({:name => 'zoom' ,:show_filter => true})
			cat.specs.new({:name => 'Type' ,:show_filter => true})
			cat.specs.new({:name => 'Memory' ,:show_filter => false})
			cat.save


			cat1 = cat.subcategories.create({:name => "CamCoders"})
			cat1.products.new({:name => "Sony"})
			cat1.specs.new({:name => 'Mega pixel' ,:show_filter => true})
			cat1.specs.new({:name => 'zoom' ,:show_filter => true})
			cat1.specs.new({:name => 'Type' ,:show_filter => true})
			cat1.specs.new({:name => 'Memory' ,:show_filter => false})
			cat1.save


		#laptop

		cat = P2p::Category.create({:name => "Computer"})

			cat1 = cat.subcategories.create({:name => "Laptop"})
			cat2 = cat.subcategories.create({:name => "Tablet"})

			cat1.products.new({:name => "HP"})
			cat1.products.new({:name => "DELL"})
			cat1.products.new({:name => "Apple"})
			cat1.products.new({:name => "Sony Viao"})
			cat1.products.new({:name => "Compaq"})
			cat1.products.new({:name => "Lenovo"})

			cat1.specs.new({:name => 'OS' ,:show_filter => true})
			cat1.specs.new({:name => 'RAM' ,:show_filter => true})
			cat1.specs.new({:name => 'Storage' ,:show_filter => true})
			cat1.specs.new({:name => 'Screen Size' ,:show_filter => true})
			cat1.specs.new({:name => 'Processor' ,:show_filter => true})

			cat1.specs.new({:name => 'Connectivity' ,:show_filter => false})
			cat1.specs.new({:name => 'Camera' ,:show_filter => false})
			cat1.specs.new({:name => 'Audio' ,:show_filter => false})
			cat1.specs.new({:name => 'KeyPad' ,:show_filter => false})
			cat1.specs.new({:name => 'USB' ,:show_filter => false})
			cat1.specs.new({:name => 'VGA' ,:show_filter => false})
			cat1.specs.new({:name => 'mini-Card slot' ,:show_filter => false})
			cat1.specs.new({:name => 'Wifi' ,:show_filter => false})		
			cat1.specs.new({:name => 'Graphics' ,:show_filter => false})

			cat1.save

			cat2.products.new({:name => "HP"})
			cat2.products.new({:name => "DELL"})
			cat2.products.new({:name => "Apple"})
			cat2.products.new({:name => "Sony Viao"})
			cat2.products.new({:name => "Compaq"})
			cat2.products.new({:name => "Lenovo"})

			cat2.specs.new({:name => 'OS' ,:show_filter => true})
			cat2.specs.new({:name => 'RAM' ,:show_filter => true})
			cat2.specs.new({:name => 'Storage' ,:show_filter => true})
			cat2.specs.new({:name => 'Screen Size' ,:show_filter => true})
			cat2.specs.new({:name => 'Processor' ,:show_filter => true})

			cat2.specs.new({:name => 'Connectivity' ,:show_filter => false})
			cat2.specs.new({:name => 'Camera' ,:show_filter => false})
			cat2.specs.new({:name => 'Audio' ,:show_filter => false})
			cat2.specs.new({:name => 'KeyPad' ,:show_filter => false})
			cat2.specs.new({:name => 'USB' ,:show_filter => false})
			cat2.specs.new({:name => 'VGA' ,:show_filter => false})
			cat2.specs.new({:name => 'mini-Card slot' ,:show_filter => false})
			cat2.specs.new({:name => 'Wifi' ,:show_filter => false})		
			cat2.specs.new({:name => 'Graphics' ,:show_filter => false})

			cat2.save

			cat.products.new({:name => "HP"})
			cat.products.new({:name => "DELL"})
			cat.products.new({:name => "Apple"})
			cat.products.new({:name => "Sony Viao"})
			cat.products.new({:name => "Compaq"})
			cat.products.new({:name => "Lenovo"})

			cat.specs.new({:name => 'OS' ,:show_filter => true})
			cat.specs.new({:name => 'RAM' ,:show_filter => true})
			cat.specs.new({:name => 'Storage' ,:show_filter => true})
			cat.specs.new({:name => 'Screen Size' ,:show_filter => true})
			cat.specs.new({:name => 'Processor' ,:show_filter => true})

			cat.specs.new({:name => 'Connectivity' ,:show_filter => false})
			cat.specs.new({:name => 'Camera' ,:show_filter => false})
			cat.specs.new({:name => 'Audio' ,:show_filter => false})
			cat.specs.new({:name => 'KeyPad' ,:show_filter => false})
			cat.specs.new({:name => 'USB' ,:show_filter => false})
			cat.specs.new({:name => 'VGA' ,:show_filter => false})
			cat.specs.new({:name => 'mini-Card slot' ,:show_filter => false})
			cat.specs.new({:name => 'Wifi' ,:show_filter => false})		
			cat.specs.new({:name => 'Graphics' ,:show_filter => false})

			cat.save

			#Accessories
		cat = P2p::Category.create({:name => "Accessories"})

			cat.products.new({:name => "Zebronics"})

			cat.specs.new({:name => 'Accessory for' ,:show_filter => true})

			cat.save

		# Storage Devices
		cat = P2p::Category.create({:name => "Storage Devices"})
			cat1 = cat.subcategories.create({:name => 'Pen Drive'})
			cat2 = cat.subcategories.create({:name => 'Memory Card'})
			cat3 = cat.subcategories.create({:name => 'Hard Disk'})


			cat1.specs.new({:name => 'Capacity' ,:show_filter => true})
			cat1.save

			cat2.specs.new({:name => 'Capacity' ,:show_filter => true})
			cat2.save

			cat3.specs.new({:name => 'Capacity' ,:show_filter => true})
			cat3.save


			cat.specs.new({:name => 'Capacity' ,:show_filter => true})
			cat.save

		# Games
		cat = P2p::Category.create({:name => "Games"})

		cat.specs.new({:name => 'Platform' ,:show_filter => true})
		cat.specs.new({:name => 'Type' ,:show_filter => true})

		cat.save

		# Clothing
		cat = P2p::Category.create({:name => "Clothing"})

		cat.specs.new({:name => 'Gender' ,:show_filter => true})

		cat.save


		 P2p::ServicePincode.create(:pincode => '560038' )
		 P2p::ServicePincode.create(:pincode => '560036' )
		 P2p::ServicePincode.create(:pincode => '560043' )

		 StaticPage.create(:page_name => "p2p_aboutus", :page_title => "About us", :page_content => "About Us", :is_active => true)
		 StaticPage.create(:page_name => "p2p_contactus", :page_title => "Contact us", :page_content => "Contact Us", :is_active => true)
		 StaticPage.create(:page_name => "p2p_privacypolicy", :page_title => "Privacy Policy", :page_content => "Privacy Policy", :is_active => true)
		 StaticPage.create(:page_name => "p2p_how_to_sell", :page_title => "How to sell", :page_content => "How to sell", :is_active => true)
		 StaticPage.create(:page_name => "p2p_how_to_buy", :page_title => "How to buy", :page_content => "How to buy", :is_active => true)
		 StaticPage.create(:page_name => "p2p_buyer_protection", :page_title => "Buyer Protection", :page_content => "Buyer Protection", :is_active => true)
		 StaticPage.create(:page_name => "p2p_terms_conditions", :page_title => "Terms and conditons", :page_content => "Terms and Conditions", :is_active => true)
		 StaticPage.create(:page_name => "p2p_seller_policy", :page_title => "Seller Policy", :page_content => "Seller Policy", :is_active => true)
		 StaticPage.create(:page_name => "p2p_buyer_policy", :page_title => "Buyer Polciy", :page_content => "Buyer Policy", :is_active => true)