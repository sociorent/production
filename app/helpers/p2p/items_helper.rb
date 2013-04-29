module P2p::ItemsHelper
	def get_states_selected(state)
  	states=["Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chandigarh","Chhattisgarh","Daman and Diu","Delhi","Goa","Gujarat","Haryana","Himachal Pradesh","Jammu and Kashmir","Jharkhand","Karnataka","Kerala","Madhya Pradesh","Maharashtra","Manipur","Meghalaya","Mizoram","Nagaland","Orissa","Pondicherry","Punjab","Rajasthan","Sikkim","Tamil Nadu","Tripura","Uttar Pradesh","Uttarakhand","West Bengal","Dadra and Nagar Haveli","Andaman and Nicobar Islands"]
  	return_html =""
		states.each do |st|
			selected = (state == st)? "selected='selected'" : ""
			return_html += "<option value='#{st}' #{selected}>#{st}</option>"
		end
		return_html
	end
end
