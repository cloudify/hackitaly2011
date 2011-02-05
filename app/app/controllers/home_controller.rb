class HomeController < ApplicationController
  respond_to :html, :mobile

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
      session[:user] = ActiveSupport::JSON.decode(breq.body)
      redirect_to '/'
  end

  def logout
    session[:user] = nil
    redirect_to '/'
  end
end
