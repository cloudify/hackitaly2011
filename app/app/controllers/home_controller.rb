class HomeController < ApplicationController
  
  def index
    @current_user = session[:user] 
  end
  
  def login
    breq = Typhoeus::Request.get("http://api.beintoo.com/api/rest/player/login",
      :method        => :get,
      :headers       => {
        :apikey => "8efa78d626e15a7c5c72fa442f5793",
        :guid => params[:login]
      })
      @current_user = JSON.parse(bresp.body)
      
      render 'index'
  end
  
end
