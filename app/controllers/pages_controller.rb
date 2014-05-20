class PagesController < ApplicationController
  
  def index
    @section = 'home'
  end
  
  def sso
    @users = User.all
    @sso_init_endpoint = "http://localhost:8888/maestrano/auth/saml/init.php"
  end
  
  def app_access_unauthorized
    
  end
end