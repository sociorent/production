class AddShippedDateToBookOrders < ActiveRecord::Migration
  def change
    add_column :book_orders, :shipped_date, :timestamp
  end
end
