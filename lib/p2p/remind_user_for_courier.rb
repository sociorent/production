# (p..p1).select{|d| (1..5).include?(d.wday)}

P2p::Item.sold.where('paytype = 1 ').each do |item|
	days = (item.solddate..DateTime.now).select{|d| (1..5).include?(d.wday).count}

	days.size > item.payinfo.to_i

end