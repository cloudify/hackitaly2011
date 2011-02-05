class HomeController < ApplicationController

  respond_to :html, :mobile
  
  @@beintoo_apikey = "8efa78d626e15a7c5c72fa442f5793"
  @@playme_apikey = "4c3131495653414882"
  
  def index
    @current_user = session[:user] 
    chart_req = Typhoeus::Request.get("http://api.beintoo.com/api/rest/app/topscore",
      :method        => :get,
      :headers       => {
        :apikey => '1234567890'
      })
    
    @top_users = ActiveSupport::JSON.decode(chart_req.body).collect{ |p| p['score'] = p['entry'].andand['playerScore'].andand['default'].andand['balance'].to_i; p }.sort do |a,b|
      b['score'] <=> a['score']
    end
  end

  def login
    breq = Typhoeus::Request.get("http://api.beintoo.com/api/rest/player/login",
      :method        => :get,
      :headers       => {
        :apikey => @@beintoo_apikey,
        :guid => params[:login]
      })
      session[:user] = ActiveSupport::JSON.decode(breq.body)
      session[:guid] = params[:login]
      redirect_to '/'
  end

  def logout
    session[:user] = nil
    redirect_to '/'
  end
  
  def submitresult
    req = Typhoeus::Request.get("http://api.beintoo.com/api/rest/player/submitscore",
      :method        => :get,
      :headers       => {
        :apikey => @beintoo_apikey,
        :guid => session[:guid]
      },
      :params => {
        :lastScore => (params[:result] ? 1 : -1) * Math.rand(5).to_i + 5
      })
  end
  
  def playme
    req = Typhoeus::Request.get("http://api.playme.com/genre.getTrack",
      :method        => :get,
      :params => {
        :apikey => @@playme_apikey,
        :step => params[:step],
        :format => "json",
        :genreCode => params[:genreCode]
      })
    render :json => ActiveSupport::JSON.decode(req.body)
  end
end
