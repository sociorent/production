

P2p::Image.where('process_status = 1').each do |img|
	img.img.reprocess
	img.process_status = 2 
	img.save
end