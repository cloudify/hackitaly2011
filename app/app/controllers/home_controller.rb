class HomeController < ApplicationController

  respond_to :html, :mobile
  
  @@beintoo_apikey = "8efa78d626e15a7c5c72fa442f5793"
  @@playme_apikey = "4c3131495653414882"
  
  def index
    @current_user = session[:user]
    
    if params[:web] == '1'
      render :template => 'home/web', :layout => false 
    end
  end
  
  def gettopscores
    chart_req = Typhoeus::Request.get("http://api.beintoo.com/api/rest/app/topscore",
      :method        => :get,
      :headers       => {
        :apikey => '1234567890'
      })
    
    @top_users = ActiveSupport::JSON.decode(chart_req.body)
    
    if !@top_users
      render :json => {:status => :error} and return
    end
    
    @top_users = @top_users.collect{ |p| p['score'] = p['entry'].andand['playerScore'].andand['default'].andand['balance'].to_i; p }.sort do |a,b|
      b['score'] <=> a['score']
    end
    
    render :json => @top_users
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
      redirect_to '/?web=' + params[:web].to_i.to_s
  end

  def logout
    session[:user] = nil
    redirect_to '/?web=' + params[:web].to_i.to_s
  end
  
  def submitresult
    req = Typhoeus::Request.get("http://api.beintoo.com/api/rest/player/submitscore",
      :method        => :get,
      :headers       => {
        :apikey => @@beintoo_apikey,
        :guid => session[:guid]
      },
      :params => {
        :lastScore => params[:result] == '1' ? 1 : -1
      })
    req = Typhoeus::Request.get("http://api.beintoo.com/api/rest/player/byguid/" + session[:guid].to_s,
      :method        => :get,
      :headers       => {
        :apikey => @@beintoo_apikey
      })
      render :text => req.body
  end
  
  def topusers
  end

  def tracks
    req = Typhoeus::Request.get("http://api.playme.com/genre.getTracks",
      :method        => :get,
      :params => {
        :apikey => @@playme_apikey,
        :step => params[:step],
        :format => "json",
        :genreCode => params[:genreCode]
      })
    render :json => req.body
  end
  
  def getplayer
    req = Typhoeus::Request.get("http://api.beintoo.com/api/rest/player/byguid/" + session[:guid].to_s,
      :method        => :get,
      :headers       => {
        :apikey => @@beintoo_apikey
      })
      render :text => req.body
  end
  
end
