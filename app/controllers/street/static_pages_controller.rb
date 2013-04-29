class Street::StaticPagesController < ApplicationController

  layout :p2p_layout

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


  def aboutus
    @page = StaticPage.find_by_page_name('p2p_aboutus')
    render :getpage
  end

  def contactus
    @page = StaticPage.find_by_page_name('p2p_contactus')
    render :getpage
  end

  def privacypolicy
    @page = StaticPage.find_by_page_name('p2p_privacypolicy')
    render :getpage
  end

  def howtosell
    @page = StaticPage.find_by_page_name('p2p_how_to_sell')
    render :getpage
  end

  def howtobuy
    @page = StaticPage.find_by_page_name('p2p_how_to_buy')
    render :getpage
  end

  def buyerprotection
    @page = StaticPage.find_by_page_name('p2p_buyer_protection')
    render :getpage
  end

  def terms
    @page = StaticPage.find_by_page_name('p2p_terms_conditions')
    render :getpage
  end

  def sellerpolicy
    @page = StaticPage.find_by_page_name('p2p_seller_policy')
    render :getpage
  end

  def buyerpolicy
    @page = StaticPage.find_by_page_name('p2p_buyer_policy')
    render :getpage
  end

  def show
    @page = StaticPage.find_by_page_name(params[:id])
  end
  
end
