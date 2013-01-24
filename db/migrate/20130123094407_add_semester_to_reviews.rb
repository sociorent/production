class AddSemesterToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :semester, :string
  end
end
