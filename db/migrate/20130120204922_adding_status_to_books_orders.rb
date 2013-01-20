class AddingStatusToBooksOrders < ActiveRecord::Migration
  def change
  	add_column :book_orders , :status, :string
  end
end
