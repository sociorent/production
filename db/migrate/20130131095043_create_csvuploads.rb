class CreateCsvuploads < ActiveRecord::Migration
  def change
    create_table :csvuploads do |t|
      t.string :csv
      t.integer :books_uploaded
      t.integer :total_books
      t.text :isbns_not_uploaded
      t.string :status
      t.timestamps
    end
  end
end
