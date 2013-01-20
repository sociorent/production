class CreateShippings < ActiveRecord::Migration
  def change
    create_table :shippings do |t|
    	t.references :book_order
      t.timestamps
    end
  end
end
