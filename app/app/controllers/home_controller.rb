class HomeController < ApplicationController
  
  @@apikey = "8efa78d626e15a7c5c72fa442f5793"
  
  def index
    @current_user = session[:user] 
    chart_req = Typhoeus::Request.get("http://api.beintoo.com/api/rest/app/topscore",
      :method        => :get,
      :headers       => {
        :apikey => @@apikey
      })
    @top_users = ActiveSupport::JSON.decode(chart_req.body)
  end
  
  def login
    breq = Typhoeus::Request.get("http://api.beintoo.com/api/rest/player/login",
      :method        => :get,
      :headers       => {
        :apikey => @@apikey,
        :guid => params[:login]
      })
      session[:user] = ActiveSupport::JSON.decode(breq.body)
      redirect_to root_url
  end
  
  def logout
    session[:user] = nil
    redirect_to root_url
  end
  
end
