class PagesController < ApplicationController
  
  def index
    @section = 'home'
  end
  
  def sso
    @section = 'sso'
    @users = User.all
    @sso_init_endpoint = (session[:sso_init_endpoint] || "http://localhost:8888/maestrano/auth/saml/index.php")
  end
  
  def sso_trigger
    session[:current_user] = params[:user_uid]
    session[:sso_init_endpoint] = params[:sso_init_endpoint]
    sso_redirect_url = "#{params[:sso_init_endpoint]}?group_id=#{params[:group_id]}"
    
    redirect_to sso_redirect_url
  end
  
  def app_access_unauthorized
    
  end
end