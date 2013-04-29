class ErrorsController < ApplicationController

  def routing
    begin    
      if request.env['HTTP_REFERER'].index('street')
        redirect_to '/street' ,:notice => "Page not found"
      else
        redirect_to '/'  ,:notice => "Page not found"
      end
    rescue
        redirect_to '/'  ,:notice => "Page not found"
    end

  end

  def ignore_routing
  	render :nothing=>true
  	return
  end

  def index
  	render "errors/errors"
  end

end