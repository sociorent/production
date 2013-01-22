ActiveAdmin.register Book do

	collection_action :rented_books do
		@number_of_books = 0
	  count = 10
	  @colleges = College.pluck(:name)
	  @rented_books = []
	  @orders = Order.includes(:books).all
	  @orders.each do |order|
		  if @rented_books.count <= count
	      @rented_books += order.books
	      @number_of_books += order.books.count
	    else
	       @number_of_books += order.books.count
	    end
	  end
    @rented_books = @rented_books.first(count)
	end
	action_item :only => [:index] do
    link_to('Rented Books',rented_books_admin_books_path())
  end

	index do
		selectable_column
		column :name
		column :isbn13
		column :price
		count = 0
  	column :description do |d|
  		count+=1
  		d.description.gsub! /'/, '|'
  		raw "<a class='view_description button' show-desc='#{count}'>View Description</a> <input id='#{count}' type='hidden' value='#{d.description}'/>"
  	end
  	render :partial => "admin/book/index"
  	default_actions
  end
  show do |ad|
      attributes_table do
        row :name
        row :author
        row :isbn10
        row :isbn13
        row :description
        row :binding
        row :pages
        row :published
        row :price
        row :strengths
        row :weaknesses
        row :edition
        row :rank
        row :availability
        row :category
        row :publisher
        row :images do |book|
          image_tag(book.images.first.image, :width=>100)
        end
      end
      active_admin_comments
    end
  form do |f|


  	f.inputs "Book" do
	  	f.input :name
	  	f.input :author
	  	f.input :isbn13
	  	f.input :isbn10
	  	f.input :description
	  	f.input :binding
	  	f.input :pages
	  	f.input :published
	  	f.input :price
	  	f.input :strengths
	  	f.input :weaknesses
	  	f.input :edition
	  	f.input :rank
	  	f.input :availability
	  	f.input :category
	  	f.input :publisher
  		f.has_many :images do |img_f|
  			img_f.inputs "Image" do
          puts img_f.object.new_record?
          if img_f.object.new_record?
            img_f.input :image
          else
            img_f.input :image,:hint =>img_f.template.image_tag(img_f.object.image,:width=>100)
          end
        end
     	end
      f.buttons
  	end
  end
end
