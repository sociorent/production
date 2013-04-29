class ApplicationController < ActionController::Base

 # Helper method for all views
 helper_method  :p2p_current_user ,:p2p_get_user_location

 helper_method :make_item_url ,:make_product_url ,:make_category_url

 if Rails.env.production?

  rescue_from Exception, :with => :server_error
 end

#time
 before_filter :set_start_time

 def set_start_time
    @start_time = Time.now.usec
  end
#time

  protect_from_forgery
  def send_sms(receipient,msg)
   user_pwd="Sathish@sociorent.com:Sathish1"
   sender_id="SOCRNT"
   url= "http://api.mVaayoo.com/mvaayooapi/MessageCompose?user=#{user_pwd}&senderID=#{sender_id}&receipientno=#{receipient}&dcs=0&msgtxt=#{msg}&state=4"
   puts url
   agent =Mechanize.new
   page = agent.get(url)
   resp=page.body.split(",")
   puts page.body

   # puts receipient
   # puts msg
   # resp = ["Status=1"]
   puts resp
   if resp[0]=="Status=1"
    return false
   elsif resp[0] == "Status=0"
    return true
   end
  end

  def render_error(exception)

    UserMailer.error_mail(exception).deliver()

    if request.env['HTTP_REFERER'].index('street')
      redirect_to '/street' ,:notice => "Page not found"
    else
      redirect_to '/'  ,:notice => "Page not found"
    end

  end



  def guess_user_location
    begin

        if !session.has_key?(:city)

        if cookies.has_key?(:city) and cookies[:city]!= '' and !cookies[:city].nil?
            city = P2p::City.find_or_create_by_name(cookies[:city])
            session[:city] = city.name
            session[:city_id] = city.id
            cookies.permanent[:city] = session[:city]

            unless current_user.nil?
              user = P2p::User.find_by_user_id(current_user.id)

              if user
                user.city = P2p::City.find(session[:city_id])
                user.save
                return
              end
            end
        end

          geocode  = Geocoder.search(request.env['REMOTE_ADDR'])
          #geocode  = Geocoder.search('106.51.91.235')


          if geocode.count >0 and geocode[0].data["city"] != ''
            session[:city] = geocode[0].data["city"]
            session[:city_id] = P2p::City.find_or_create_by_name(session[:city]).id
              cookies.permanent[:city] = session[:city]

              #save if user logged in
              unless current_user.nil?
                user = P2p::User.find_by_user_id(current_user.id)

                if user
                  user.city = P2p::City.find(session[:city_id])
                  user.save
                end
              end

          else

        session.delete(:city)
          session.delete(:city_id)
        end
      else

        if session[:city] == '' or session[:city].nil?
          session.delete(:city)
          session.delete(:city_id)
        end

        end
    rescue Exception => ex
      redirect_to '/'
    end
  end


  def p2p_get_user_location
    if session.has_key?(:city) and session.has_key?(:city_id)
      return session[:city_id]
    else
      return nil
    end
  end

  ##P2P layout
  # this selects the layout for the p2p namespace
  def p2p_layout

   if request.xhr?
    return false;
   else
    guess_user_location
    return 'p2p_layout'
    #return 'application'
   end
  end
# tr('!@#$%^&\*\(\),-\{\}<>\./\\\\|\]\[;:"_\+\?', "")

  # urlss
  def make_item_url(item)
    return URI.encode("/street/#{item.category.name.gsub(/[^0-9A-Za-z]/, '')}/#{item.category.id}/#{item.product.name.gsub(/[^0-9A-Za-z]/, '')}/#{item.product.id}/#{item.title.gsub(/[^0-9A-Za-z]/, '')}/#{item.id}/")
  end

  def make_product_url(product)
    return URI.encode("/street/#{product.category.name.gsub(/[^0-9A-Za-z]/, '')}/#{product.category.id}/#{product.name.gsub(/[^0-9A-Za-z]/, '')}/#{product.id}/")
  end

  def make_category_url(category)
    return URI.encode("/street/#{category.name.gsub(/[^0-9A-Za-z]/, '')}/#{category.id}/")
  end

  # urlss


  def set_location_variables(city)
  end

  ##return p2pUser
  def p2p_current_user

    user = nil

    begin
    session[:isadmin] = false

    socio_admin = User.find_by_is_admin(1)
    session[:admin_id] = (P2p::User.find_or_create_by_user_id(socio_admin.id)).id

      if current_user.nil?
        session[:userid] = nil
        return nil
      else
        user = P2p::User.find_or_create_by_user_id(current_user.id)

        session[:user_type] = user.user_type
        session[:userid] = user.id

      begin
        if user.city
          session[:city] =user.city.name
          session[:city_id] =user.city.id
          cookies.permanent[:city] = session[:city]

        elsif session.has_key?(:city)
          user.city = P2p::City.find(session[:city_id])
          user.save
        end
      rescue
        session.delete(:city)
        session.delete(:city_id)
      end

        if user.user.is_admin
          session[:isadmin] = true
        end


        return user
      end

    rescue

    end
    return user
  end

  ##P2p Authentication
  def p2p_user_signed_in
   if current_user.nil?
    redirect_to '/street/'
    return false
   end
  end


  def check_p2p_user_presence
    #set user variables
    if !current_user.nil? and session[:userid].nil?
      #call it so it sets the needed variables
      cookies.delete(:return_url)
      p2p_current_user
    end

    unless request.xhr?
      guess_user_location
    end

  # check for ucrrent user and ignore the user presnce if the user is not logged in
  if current_user.nil?
    session[:return_url] = "http://#{request.env['HTTP_HOST']}#{request.env['ORIGINAL_FULLPATH']}"
    return true
  end

  if P2p::User.find_by_user_id(current_user.id).nil?
    return false
  end

  end

  def to_hash(obj)
     hash = {}; obj.attributes.each { |k,v| hash[k.to_sym] = v }
   return hash
  end

  def p2p_is_admin
    if !session[:isadmin]
      return false
    end
    return true
  end

  def after_sign_in_path_for(resource)
    unless request.xhr?

      begin

        if cookies.has_key?(:return_url)
          return cookies[:return_url]
        end

        if (session.has_key?(:return_url))
          return session[:return_url]
        end

        if ( request.env['HTTP_REFERER'].index('devise') == nil or (request.env['HTTP_REFERER'] != (request.env['HTTP_HOST'] + request.env['REQUEST_PATH']))) and request.env["HTTP_REFERER"]
            return request.env["HTTP_REFERER"]
          else
            return '/'
        end
      rescue
        return '/'
      end

    else
      return '/'
    end
  end

  def after_sign_out_path_for(resource)
    unless request.xhr?
      begin
      if ( request.env['HTTP_REFERER'].index('devise') == nil or (request.env['HTTP_REFERER'] != (request.env['HTTP_HOST'] + request.env['REQUEST_PATH']))) and request.env["HTTP_REFERER"]
          return request.env["HTTP_REFERER"]
        else
          return '/'
      end
    rescue
      return '/'
    end
    else
      return '/'
    end
  end

  def server_error(exception)


    # Whatever code that handles the exception

    begin
      UserMailer.error_mail(exception,request,session,params).deliver()
      begin
        if request.env['HTTP_REFERER'].index('street')
          redirect_to '/street' ,:notice => "Page not found"
        else
          redirect_to '/'  ,:notice => "Page not found"
        end
      rescue
         redirect_to '/'  ,:notice => "Page not found"
      end
    rescue

        begin
          @street = ( (req.env['HTTP_REFERER'].index('street').nil?) ? '' : 'Street' )
        rescue
          @street = ""
        end

        @ex = CGI.escapeHTML(exception.inspect)
        @ex_backtrace = CGI.escapeHTML(exception.backtrace.inspect)
        @session = CGI.escapeHTML(session.inspect)
        @params = CGI.escapeHTML(params.inspect)
        @request = CGI.escapeHTML(request.inspect)

        time_now = Time.now
        aa ="

        <br/><br/><br/><br/>
        <hr/>
        *********************************************
        Start #{time_now}
        *********************************************

        <style>
        .error{
          color:red;
        }
        </style>

        <h2><span class='error'> Error Occured in Sociorent #{@street}
        </span></h2>

        <body>


            <h3>Exception obj:</h3> <pre> #{@ex}</pre>
            <br/><hr><br/>

            <h3>BackTrace :</h3>  <pre>  #{@ex_backtrace} </pre>

            <br/><hr><br/>

            <h3>Session Dump:</h3> <pre>#{ @session}</pre>

            <br/><hr><br/>

            <h3>Params Dump: </h3> <pre>#{ @params} </pre>

            <br/><hr><br/>

            <h3>Request Dump: </h3>
              <pre> #{ @request} </pre>

              <br/><hr><br/>

        *********************************************
        End #{time_now}
        *********************************************

    "

        File.open(Rails.root.join('public/tech_errors.html'), 'a+') { |file| file.write(aa) }
        #send_sms('8951173103',"Thanks for signing-up with Sociorent.com. Your ID is 'Error in sociorent. Mail not working. Find at error logged at sociorent.com/tech_errors.html' . You may now login to place your order. Thank you.")

        begin
          if request.env['HTTP_REFERER'].index('street')
            redirect_to '/street' ,:notice => "Page not found"
            return
          else
            redirect_to '/'  ,:notice => "Page not found"
            return
          end
        rescue
          redirect_to '/'  ,:notice => "Page not found"
          return
        end

    end

  end


  private
    def add_www_subdomain
     unless /^www/.match(request.host)
      redirect_to "http://www.sociorent.com"
     end
    end

    def authenticate_admin!
     authenticate_user!
     unless current_user.is_admin?
      flash[:alert] = "Unauthorized Access!"
      redirect_to root_path
     end
    end


end
