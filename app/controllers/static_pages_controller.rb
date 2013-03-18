class StaticPagesController < ApplicationController
  layout "p2p_layout"

  def new
    @page = StaticPage.new
  end

  def create
    page = StaticPage.create(params[:static_page])
  end

  def edit
    @page = StaticPage.find(params[:id])
  end

  def update
    @page = StaticPage.find(params[:id])
    @page = @page.update_attributes(params[:static_page])
  end

  def get_page
    @page = StaticPage.find_by_page_name(params[:page_name])
    render :json => @page
  end

  def show
    @page = StaticPage.find_by_page_name(params[:id])
  end
  
end
