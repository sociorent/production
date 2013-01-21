class ErrorsController < ApplicationController
  def routing
   flash[:warning] = "Page not found"
   #redirect_to "/"
  end
  def ignore_routing
  end
end