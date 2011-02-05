class HomeController < ApplicationController
  
  def index
    @current_user = session[:user] 
  end
  
  def login
    
  end
  
end
