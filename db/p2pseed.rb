
# load Rails.root.to_s + '/db/p2pseed.rb'

		
		user1 = User.find_by_name('Admin')
		user = P2p::User.new
		user.user = user1
		user.save



		cat = P2p::Category.create({:name => "Mobile"})
			
			cat.products.new({:name => "Nokia"})
			cat.products.new({:name => "Sony"})
			cat.products.new({:name => "Samsung"})
			cat.products.new({:name => "LG"})

			cat.specs.new({:name => 'OS'})
			cat.specs.new({:name => 'color'})
			cat.specs.new({:name => 'weight'})
			cat.specs.new({:name => 'Year'})

			cat.save

		cat = P2p::Category.create({:name => "Laptop"})
			
			cat.products.new({:name => "Nokia"})
			cat.products.new({:name => "Sony"})
			cat.products.new({:name => "Samsung"})
			cat.products.new({:name => "LG"})

			cat.specs.new({:name => 'OS'})
			cat.specs.new({:name => 'color'})
			cat.specs.new({:name => 'weight'})
			cat.specs.new({:name => 'Year'})

			cat.save

		cat = P2p::Category.create({:name => "Laptop Accessories"})
			cat = cat.subcategories.create({:name => "Keyboard"})

			cat.products.new({:name => "Zebronic"})
			cat.products.new({:name => "LG"})
			cat.products.new({:name => "iball"})
			cat.products.new({:name => "HP"})

			cat.specs.new({:name => 'color'})
			cat.specs.new({:name => 'weight'})
			cat.specs.new({:name => 'Year'})

			cat.save




		cat1 = P2p::Category.create({:name => "Book"})


			cat1.specs.new({:name => 'Pages'})
			cat1.specs.new({:name => 'semester'})
			cat1.specs.new({:name => 'college'})

			cat1.subcategories.create({:name => "Mathematics"})
			cat1.subcategories.create({:name => "Physics"})
			cat1.subcategories.create({:name => "Chemistry"})
			cat1.subcategories.create({:name => "C Language"})
			cat1.subcategories.create({:name => "C++"})
			cat1.subcategories.create({:name => "Ruby"})

			cat1.save

			cat1.subcategories.each do |scat|

				scat.products.new({:name => "Wrox"})
				scat.products.new({:name => "Narosa"})
				scat.products.new({:name => "Pearson"})
				scat.save

			end



		condition = ['old','new','used']
		approved = [Time.now,'']

		P2p::Category.all.each do |cat|

			cat.products.each do |prod|

					20.times do  |i|
						p = user.items.create({:title => prod.name + ' ' + i.to_s ,
												:price => rand(1000..10000),
												:desc => "Test description for " + prod.name + ". This description is short and has to be edited for getting a long description. Thank you.",
												:condition => condition[ rand(0..(condition.size-1) )]  ,
												:approveddate =>  approved[rand(0..(approved.size-1))]
												 })
						p.user = user
						p.save

					end
				end
			end



		def seed_specs(cat,spec,arr)

			spec = cat.specs.find_by_name(spec)

			cat.items.each do |itm|
				itemspec1= itm.specs.new({:value => arr[rand(0..(arr.size-1))]})
				itemspec1.spec = spec
				itemspec1.save
			end

		end

		seed_specs(P2p::Category.find_by_name('Mobile'),'OS',['symbian','bada','Android 2.3'])
		seed_specs(P2p::Category.find_by_name('Mobile'),'color',['red','blue','black','grey'])
		seed_specs(P2p::Category.find_by_name('Mobile'),'weight',[1,1.2,3.2,2.8,2.3,1.7,3.9])
		seed_specs(P2p::Category.find_by_name('Mobile'),'Year',[2012,2010,2002])


		seed_specs(P2p::Category.find_by_name('Laptop'),'OS',['Win7','Win8','DOS','Lion','ubuntu'])
		seed_specs(P2p::Category.find_by_name('Laptop'),'color',['red','blue','black','grey'])
		seed_specs(P2p::Category.find_by_name('Laptop'),'weight',[1,1.2,3.2,2.8,2.3,1.7,3.9])
		seed_specs(P2p::Category.find_by_name('Laptop'),'Year',[2012,2010,2002])

		seed_specs(P2p::Category.find_by_name('Keyboard'),'color',['red','blue','black','grey'])
		seed_specs(P2p::Category.find_by_name('Keyboard'),'weight',[1,1.2,3.2,2.8,2.3,1.7,3.9])
		seed_specs(P2p::Category.find_by_name('Keyboard'),'Year',[2012,2010,2002])

		seed_specs(P2p::Category.find_by_name('Mathematics'),'Pages',[100,210,500,832,912,529,1029,823,923,458])
		seed_specs(P2p::Category.find_by_name('Mathematics'),'semester',[1,2,3,4,5,6,7,8])
		seed_specs(P2p::Category.find_by_name('Mathematics'),'college',['VIT','SRM','NIT','IIT'])

		seed_specs(P2p::Category.find_by_name('Physics'),'Pages',[100,210,500,832,912,529,1029,823,923,458])
		seed_specs(P2p::Category.find_by_name('Physics'),'semester',[1,2,3,4,5,6,7,8])
		seed_specs(P2p::Category.find_by_name('Physics'),'college',['VIT','SRM','NIT','IIT'])

		seed_specs(P2p::Category.find_by_name('Chemistry'),'Pages',[100,210,500,832,912,529,1029,823,923,458])
		seed_specs(P2p::Category.find_by_name('Chemistry'),'semester',[1,2,3,4,5,6,7,8])
		seed_specs(P2p::Category.find_by_name('Chemistry'),'college',['VIT','SRM','NIT','IIT'])

		seed_specs(P2p::Category.find_by_name('C Language'),'Pages',[100,210,500,832,912,529,1029,823,923,458])
		seed_specs(P2p::Category.find_by_name('C Language'),'semester',[1,2,3,4,5,6,7,8])
		seed_specs(P2p::Category.find_by_name('C Language'),'college',['VIT','SRM','NIT','IIT'])

		seed_specs(P2p::Category.find_by_name('C++'),'Pages',[100,210,500,832,912,529,1029,823,923,458])
		seed_specs(P2p::Category.find_by_name('C++'),'semester',[1,2,3,4,5,6,7,8])
		seed_specs(P2p::Category.find_by_name('C++'),'college',['VIT','SRM','NIT','IIT'])

		seed_specs(P2p::Category.find_by_name('Ruby'),'Pages',[100,210,500,832,912,529,1029,823,923,458])
		seed_specs(P2p::Category.find_by_name('Ruby'),'semester',[1,2,3,4,5,6,7,8])
		seed_specs(P2p::Category.find_by_name('Ruby'),'college',['VIT','SRM','NIT','IIT'])



			cat1.subcategories.create({:name => "Physics"})
			cat1.subcategories.create({:name => "Chemistry"})
			cat1.subcategories.create({:name => "C Language"})
			cat1.subcategories.create({:name => "C++"})
			cat1.subcategories.create({:name => "Ruby"})


		#seed images inside the items



		def seed_images(cat,image_arr)
			cat.items.each do |itm|

				img = P2p::Image.new
				img1 = P2p::Image.new
				img2 = P2p::Image.new
				puts "Seeding for #{itm}"
			   	
			   	img.picture_from_url(image_arr[rand(0..(image_arr.size-1))])
			   	img.save

			   	img1.picture_from_url(image_arr[rand(0..(image_arr.size-1))])
			   	img1.save

			   	img2.picture_from_url(image_arr[rand(0..(image_arr.size-1))])
			   	img2.save

			   	itm.images << [img,img1,img2]
			  puts "Done"
			  puts "--------------------------------------"
			end

		end

   
	mobile_url=["http://i-cdn.phonearena.com/images/phones/31977-xlarge/Nokia-Lumia-710.jpg",
				"http://t3.gstatic.com/images?q=tbn:ANd9GcSSbNh9hidijRJv9041_V7P_xnv1hzzWSpyGeKNzroW6OYGSKLR",
				"https://betalabs.nokia.com/sites/default/files/rebekahjwarren/13.png",
				"http://www.techdigest.tv/Nokia%20E72.png"
	]


	laptop_url=["http://www.uneekcomputer.com/images/laptop.png",
				"http://blurbomat.com/wp/wp-content/uploads/2008/10/081014-macbook.png",
				"http://www.popgadget.net/images/overview-laptop.png",
				"http://www.intel.com/content/dam/www/public/us/en/apps/decision-tool/img/en-us/laptop/value.png",
	]

	keyboard_url = ["http://www.umpcportal.com/gallery/d/41425-1/touchpad-accessories-keyboard.png",
		"http://files.softicons.com/download/system-icons/hydropro-icons-by-mediadesign/png/512/HP-Keyboard.png",
		"http://icons.iconarchive.com/icons/archigraphs/mac/512/Keyboard-icon.png",
		"http://files.softicons.com/download/system-icons/dark-light-suite-icons-by-alejandro-lopez/png/256/Hardware%20Keyboard.png"
	]

	book_url =["http://slimemansion.com/artwork/original/destiny/bookcover.jpg",
	"http://www.marlenecaldes.com/images/Terrence%20Real%20BOOK-COVER.jpg",
	"http://images6.fanpop.com/image/photos/32500000/NOT-A-REAL-BOOK-BUT-A-COVER-OF-A-ROLE-PLAY-forever-warriors-cats-32523884-436-648.gif",
	"http://farm3.staticflickr.com/2726/4407059676_39223bdea9_z.jpg",
	"http://www.compassbookratings.com/wp-content/uploads/2012/03/heaven-is-for-real.jpg",
	"http://th01.deviantart.net/fs70/PRE/i/2012/177/5/a/the_real_treasure_book_cover_1_by_legoboa-d54xyu4.jpg",
	"http://product-images.wantist.com/photos/1187/Cooking_for_Geeks_Real_Science_Great_Hacks_and_Good_Food_book_cover-sixhundred.jpeg?1290656983",
	"http://www.erinharner.com/uploads//Real-Food-Real-Simple-Book-Cover.jpg"
	]

	seed_images(P2p::Category.find_by_name('Mobile'),mobile_url)
	seed_images(P2p::Category.find_by_name('Laptop'),laptop_url)
	seed_images(P2p::Category.find_by_name('Keyboard'),keyboard_url)
	seed_images(P2p::Category.find_by_name('Book'),book_url)


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


