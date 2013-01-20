class ErrorsController < ApplicationController
  def routing
   flash[:warning] = "Page not found"
   #redirect_to "/"
  end
end