class HomeController < ApplicationController
  def index
  	@user = current_user
  	if @user
  		# search books by default will show last 5 books
  		@search = Book.last(5)
      # cart of the user
      cart = @user.cart
      @cart = cart.books
      # Intelligent Books
      # Using FB friends
      friend_uids = JSON.parse @user.friends
      all_uids = JSON.parse User.select("uid").to_json()
      friends_who_use_sociorent_uids = all_uids & friend_uids
      # get all books their friends ordered
      @intelligent_books = []
      friends_who_use_sociorent_uids.each do |uid|
        friend = User.where(:uid => uid["uid"]).first
        # check condition on friend from the General Setting
        general = General.first
        case general.intelligent_book
          when "All friends"
            @intelligent_books += friend.books
          when "Friends in same College"    
            @intelligent_books += friend.books if friend.college == @user.college
          when "Friends in same College and Stream" 
            @intelligent_books += friend.books if friend.college == @user.college && friend.stream == @user.stream
        end
      end
      puts @intelligent_books
      @intelligent_books.uniq
      if @intelligent_books.count == 0
        @intelligent_books = Book.offset(rand(Book.count)).first(10)
      end
  		# render inner when user is logged in
  		render "inner"
  	else
      @images = General.first.general_images.all
  		render "index"
  	end
  end

  def search
  	query = "*#{params[:query]}*"
  	@books = Book.search query
  	render :json => @books.to_json()
  end

  def book_request
    user = current_user
    user.requests.create(:title => params[:title], :author => params[:author], :isbn => params[:isbn])
    render :text => "Your request was submitted, Thank you."
  end

  def add_to_cart
    # getting common variables
    book = Book.find(params[:book].to_i)
    user = current_user
    cart = user.cart
    # add book to the cart
    cart.books << book
    cart.save
    render :json => book.to_json()
  end

  def remove_from_cart
    # getting common variables
    book = Book.find(params[:book].to_i)
    user = current_user
    cart = user.cart
    # remove book from cart
    book_cart = cart.book_carts.where(:book_id => book).first
    book_cart.delete
    render :json => book.to_json()
  end
end