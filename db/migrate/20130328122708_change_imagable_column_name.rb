class ChangeImagableColumnName < ActiveRecord::Migration
  def up
  	rename_column :images, :imageable_id , :imageable_socio_id
  	rename_column :images, :imageable_type , :imageable_socio_type
  end

  def down
  	rename_column :images, :imageable_socio_id, :imageable_id
  	rename_column :images, :imageable_socio_type , :imageable_type
  end
end
