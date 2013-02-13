
# load Rails.root.to_s + '/db/p2pseed.rb'

		User.limit(10).each do |usr|
			user = P2p::User.new
			user.user = usr
			user.save
		end

		user = P2p::User.find(1)

		puts "aa"

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

puts "aa"

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

puts "aa"
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

		puts "aa"	


		cat1 = P2p::Category.create({:name => "Book"})

			cat1.products.new({:name => "Wrox"})
			cat1.products.new({:name => "Narosa"})
			cat1.products.new({:name => "Pearson"})

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

puts "aa"

		P2p::Category.all.each do |cat|

			cat.subcategories.each do |scat|

				scat.products.each do |prod|

						10.times do  |i|
							p = prod.items.create({:title => prod.name + ' ' + i.to_s ,:price => rand(1000..10000),:desc => "Test description for #{prod}#{i}. This description is short and has to be edited for getting a long description. Thank you." ,:condition => 'old'})
							p.save
							p.user = user
							p.save
							scat.specs.each do |spec|
								s= p.specs.create({:value => spec.name + ' spec'})
								s.spec = spec
								s.save
							end
							p.save
					end

					end
				end


			cat.products.each do |prod|

					10.times do  |i|
						p = prod.items.create({:title => prod.name + ' ' + i.to_s ,:price => rand(1000..10000),:desc => "Test description for #{prod}#{i}. This description is short and has to be edited for getting a long description. Thank you.",:condition => 'old'})
						p.save
						p.user = user
						p.save

						cat.specs.each do |spec|
							s= p.specs.create({:value => spec.name + ' spec'})
							s.spec = spec
							s.save
						end
						p.save

					end
				end
			end


