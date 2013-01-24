
##== Book Dashboard
# This Activeadmin contains the management activites to 
# manage Books

ActiveAdmin.register Book do

  ## Rented Books
  #This displays all the books details
  #along with their rented and college names
  #order count etc...,
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


  ## Index action
  #  This action displays all the details of the book

	index do

    ## Column 1
    # This is a column with check box which enables admin to perform 
    # batch actions in the dashboard
		selectable_column
		
    ## Column 2
    # This column displays the name of the book
    column :name

    ## Column 3
    # This column displays the ISBN 13 of the book
		column :isbn13

    ## Column 4
    # This column displays the price of the book
		column :price

    ## Column 5
    #Description fo the book
    # ##TODO##
		count = 0
  	column :description do |d|
  		count+=1
  		d.description.gsub! /'/, '|'
  		raw "<a class='view_description button' show-desc='#{count}'>View Description</a> <input id='#{count}' type='hidden' value='#{d.description}'/>"
  	end

    #render the book index  
  	render :partial => "admin/book/index"

    ##Column 6
    # Render the default actions like view, delete, edit
    # for the books
  	default_actions
  end

  ##Show Action
  #show action displays the action 
  #of each and every book.
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


  ## From for input and edit
  # this generates the form that is used to create and edit
  # the book details
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
