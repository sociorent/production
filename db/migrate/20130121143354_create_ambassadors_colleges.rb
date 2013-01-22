class CreateAmbassadorsColleges < ActiveRecord::Migration
	def change
		create_table :ambassadors_colleges do |t|
			t.references :ambassador
			t.references :college
		end
	end
end
