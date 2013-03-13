
# load Rails.root.to_s + '/db/p2pseed.rb'

		
		user1 = User.find_by_email('admin@admin.com')
		adminuser = P2p::User.new
		adminuser.user = user1
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

	cat.specs.new({:name => 'Publisher' ,:show_filter => true})

	cat.specs.new({:name => 'ISBN-13',:show_filter => false})
	cat.specs.new({:name => 'ISBN-10',:show_filter => false})
	cat.specs.new({:name => 'Page Count',:show_filter => false})
	cat.specs.new({:name => 'Author',:show_filter => false})
	cat.specs.new({:name => 'Edition',:show_filter => false})
	cat.specs.new({:name => 'Binding',:show_filter => false})
	cat.specs.new({:name => 'Published Year',:show_filter => false})

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
				cat.subcategories.create({:name => "CamCoders"})

		cat.products.new({:name => "Sony"})

		cat.specs.new({:name => 'Mega pixel' ,:show_filter => true})
		cat.specs.new({:name => 'zoom' ,:show_filter => true})
		cat.specs.new({:name => 'Type' ,:show_filter => true})

		cat.specs.new({:name => 'Memory' ,:show_filter => false})

		cat.save


		#laptop

		cat = P2p::Category.create({:name => "Computer"})
			cat.subcategories.create({:name => "Laptop"})
			cat.subcategories.create({:name => "Tablet"})


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
			cat.subcategories.create({:name => 'Pen Drive'})
			cat.subcategories.create({:name => 'Memory Card'})
			cat.subcategories.create({:name => 'Hard Disk'})

		cat.specs.new({:name => 'Capacity' ,:show_filter => true})

		
		cat.save

		# Storage Devices
		cat = P2p::Category.create({:name => "Storage Devices"})
			cat.subcategories.create({:name => 'Pen Drive'})
			cat.subcategories.create({:name => 'Memory Card'})
			cat.subcategories.create({:name => 'Hard Disk'})

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


# *******************************************************************


	# 	condition = ['old','new','used']
	# 	approved = [Time.now,'']

	# 	P2p::Category.all.each do |cat|

	# 		cat.products.each do |prod|

	# 				20.times do  |i|
	# 					p = prod.items.create({:title => prod.name + ' ' + i.to_s ,
	# 											:price => rand(1000..10000),
	# 											:desc => "Test description for " + prod.name + ". This description is short and has to be edited for getting a long description. Thank you.",
	# 											:condition => condition[ rand(0..(condition.size-1) )]  ,
	# 											:approveddate =>  approved[rand(0..(approved.size-1))]
	# 											 })
	# 					p.user = user
	# 					p.save

	# 				end
	# 			end
	# 		end



	# 	def seed_specs(cat,spec,arr)

	# 		spec = cat.specs.find_by_name(spec)

	# 		cat.items.each do |itm|
	# 			itemspec1= itm.specs.new({:value => arr[rand(0..(arr.size-1))]})
	# 			itemspec1.spec = spec
	# 			itemspec1.save
	# 		end

	# 	end

	# 	seed_specs(P2p::Category.find_by_name('Mobile'),'OS',['symbian','bada','Android 2.3'])
	# 	seed_specs(P2p::Category.find_by_name('Mobile'),'color',['red','blue','black','grey'])
	# 	seed_specs(P2p::Category.find_by_name('Mobile'),'weight',[1,1.2,3.2,2.8,2.3,1.7,3.9])
	# 	seed_specs(P2p::Category.find_by_name('Mobile'),'Year',[2012,2010,2002])


	# 	seed_specs(P2p::Category.find_by_name('Laptop'),'OS',['Win7','Win8','DOS','Lion','ubuntu'])
	# 	seed_specs(P2p::Category.find_by_name('Laptop'),'color',['red','blue','black','grey'])
	# 	seed_specs(P2p::Category.find_by_name('Laptop'),'weight',[1,1.2,3.2,2.8,2.3,1.7,3.9])
	# 	seed_specs(P2p::Category.find_by_name('Laptop'),'Year',[2012,2010,2002])

	# 	seed_specs(P2p::Category.find_by_name('Keyboard'),'color',['red','blue','black','grey'])
	# 	seed_specs(P2p::Category.find_by_name('Keyboard'),'weight',[1,1.2,3.2,2.8,2.3,1.7,3.9])
	# 	seed_specs(P2p::Category.find_by_name('Keyboard'),'Year',[2012,2010,2002])

	# 	seed_specs(P2p::Category.find_by_name('Mathematics'),'Pages',[100,210,500,832,912,529,1029,823,923,458])
	# 	seed_specs(P2p::Category.find_by_name('Mathematics'),'semester',[1,2,3,4,5,6,7,8])
	# 	seed_specs(P2p::Category.find_by_name('Mathematics'),'college',['VIT','SRM','NIT','IIT'])

	# 	seed_specs(P2p::Category.find_by_name('Physics'),'Pages',[100,210,500,832,912,529,1029,823,923,458])
	# 	seed_specs(P2p::Category.find_by_name('Physics'),'semester',[1,2,3,4,5,6,7,8])
	# 	seed_specs(P2p::Category.find_by_name('Physics'),'college',['VIT','SRM','NIT','IIT'])

	# 	seed_specs(P2p::Category.find_by_name('Chemistry'),'Pages',[100,210,500,832,912,529,1029,823,923,458])
	# 	seed_specs(P2p::Category.find_by_name('Chemistry'),'semester',[1,2,3,4,5,6,7,8])
	# 	seed_specs(P2p::Category.find_by_name('Chemistry'),'college',['VIT','SRM','NIT','IIT'])

	# 	seed_specs(P2p::Category.find_by_name('C Language'),'Pages',[100,210,500,832,912,529,1029,823,923,458])
	# 	seed_specs(P2p::Category.find_by_name('C Language'),'semester',[1,2,3,4,5,6,7,8])
	# 	seed_specs(P2p::Category.find_by_name('C Language'),'college',['VIT','SRM','NIT','IIT'])

	# 	seed_specs(P2p::Category.find_by_name('C++'),'Pages',[100,210,500,832,912,529,1029,823,923,458])
	# 	seed_specs(P2p::Category.find_by_name('C++'),'semester',[1,2,3,4,5,6,7,8])
	# 	seed_specs(P2p::Category.find_by_name('C++'),'college',['VIT','SRM','NIT','IIT'])

	# 	seed_specs(P2p::Category.find_by_name('Ruby'),'Pages',[100,210,500,832,912,529,1029,823,923,458])
	# 	seed_specs(P2p::Category.find_by_name('Ruby'),'semester',[1,2,3,4,5,6,7,8])
	# 	seed_specs(P2p::Category.find_by_name('Ruby'),'college',['VIT','SRM','NIT','IIT'])



	# 		cat1.subcategories.create({:name => "Physics"})
	# 		cat1.subcategories.create({:name => "Chemistry"})
	# 		cat1.subcategories.create({:name => "C Language"})
	# 		cat1.subcategories.create({:name => "C++"})
	# 		cat1.subcategories.create({:name => "Ruby"})


	# 	#seed images inside the items



	# 	def seed_images(cat,image_arr)
	# 		cat.items.each do |itm|

	# 			img = P2p::Image.new
	# 			img1 = P2p::Image.new
	# 			img2 = P2p::Image.new
	# 			puts "Seeding for #{itm}"
			   	
	# 		   	img.picture_from_url(image_arr[rand(0..(image_arr.size-1))])
	# 		   	img.save

	# 		   	img1.picture_from_url(image_arr[rand(0..(image_arr.size-1))])
	# 		   	img1.save

	# 		   	img2.picture_from_url(image_arr[rand(0..(image_arr.size-1))])
	# 		   	img2.save

	# 		   	itm.images << [img,img1,img2]
	# 		  puts "Done"
	# 		  puts "--------------------------------------"
	# 		end

	# 	end

   
	# mobile_url=["http://i-cdn.phonearena.com/images/phones/31977-xlarge/Nokia-Lumia-710.jpg",
	# 			"http://t3.gstatic.com/images?q=tbn:ANd9GcSSbNh9hidijRJv9041_V7P_xnv1hzzWSpyGeKNzroW6OYGSKLR",
	# 			"https://betalabs.nokia.com/sites/default/files/rebekahjwarren/13.png",
	# 			"http://www.techdigest.tv/Nokia%20E72.png"
	# ]


	# laptop_url=["http://www.uneekcomputer.com/images/laptop.png",
	# 			"http://blurbomat.com/wp/wp-content/uploads/2008/10/081014-macbook.png",
	# 			"http://www.popgadget.net/images/overview-laptop.png",
	# 			"http://www.intel.com/content/dam/www/public/us/en/apps/decision-tool/img/en-us/laptop/value.png",
	# ]

	# keyboard_url = ["http://www.umpcportal.com/gallery/d/41425-1/touchpad-accessories-keyboard.png",
	# 	"http://files.softicons.com/download/system-icons/hydropro-icons-by-mediadesign/png/512/HP-Keyboard.png",
	# 	"http://icons.iconarchive.com/icons/archigraphs/mac/512/Keyboard-icon.png",
	# 	"http://files.softicons.com/download/system-icons/dark-light-suite-icons-by-alejandro-lopez/png/256/Hardware%20Keyboard.png"
	# ]

	# book_url =["http://slimemansion.com/artwork/original/destiny/bookcover.jpg",
	# "http://www.marlenecaldes.com/images/Terrence%20Real%20BOOK-COVER.jpg",
	# "http://images6.fanpop.com/image/photos/32500000/NOT-A-REAL-BOOK-BUT-A-COVER-OF-A-ROLE-PLAY-forever-warriors-cats-32523884-436-648.gif",
	# "http://farm3.staticflickr.com/2726/4407059676_39223bdea9_z.jpg",
	# "http://www.compassbookratings.com/wp-content/uploads/2012/03/heaven-is-for-real.jpg",
	# "http://th01.deviantart.net/fs70/PRE/i/2012/177/5/a/the_real_treasure_book_cover_1_by_legoboa-d54xyu4.jpg",
	# "http://product-images.wantist.com/photos/1187/Cooking_for_Geeks_Real_Science_Great_Hacks_and_Good_Food_book_cover-sixhundred.jpeg?1290656983",
	# "http://www.erinharner.com/uploads//Real-Food-Real-Simple-Book-Cover.jpg"
	# ]

	# seed_images(P2p::Category.find_by_name('Mobile'),mobile_url)
	# seed_images(P2p::Category.find_by_name('Laptop'),laptop_url)
	# seed_images(P2p::Category.find_by_name('Keyboard'),keyboard_url)
	# seed_images(P2p::Category.find_by_name('Book'),book_url)


		# 	cat.subcategories.each do |scat|

		# 		scat.products.each do |prod|

		# 				10.times do  |i|
		# 					p = prod.items.create({:title => prod.name + ' ' + i.to_s ,:price => rand(1000..10000),:desc => "Test description for #{prod}#{i}. This description is short and has to be edited for getting a long description. Thank you." ,:condition => 'old'})
		# 					p.save
		# 					p.user = user
		# 					p.save
		# 					scat.specs.each do |spec|
		# 						s= p.specs.create({:value => spec.name + ' spec'})
		# 						s.spec = spec
		# 						s.save
		# 					end
		# 					p.save
		# 			end

		# 			end
		# 		end


