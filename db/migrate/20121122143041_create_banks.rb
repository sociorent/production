class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
    	t.string :bank_name
    	t.text :details
      t.timestamps
    end
  end
end
