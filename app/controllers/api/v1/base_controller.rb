# This controller is inherited by all API controllers
# It is used to automatically retrieve the current_app
# corresponding to the cloud service contacting us
#
# The controller uses http basic authentication and
# retrieves the app based on its api token
class Api::V1::BaseController < ApplicationController
  before_filter :authenticate_app!
  around_filter :prepare_and_handle_error
  
  respond_to :json
  layout "api_v1"
  
  def ping
  end
  
  private
    # Authenticate the client connecting via API
    # or deny access
    def authenticate_app!
      unless app_signed_in?
        @errors = {authentication: ["Invalid API token"]}
        render template: 'api/v1/base/empty', status: :forbidden
      end
    end
    
    # Filter
    # Prepare the @errors variables
    # Catch errors and deliver standard system error
    # using the classical API response format
    def prepare_and_handle_error
      @errors = {}
      begin
        yield
      rescue Exception => e
        logger.error e
        @errors = {} # reinitialize the errors variable to hide internal errors
        @errors[:system] = ["A system error occured. Please retry later or contact support@maestrano.com if the issue persists."]
        render template: 'api/v1/base/empty', status: :internal_server_error
      end
    end
    
    # Return the currently logged in App or nil if
    # publicly accessed
    def current_app
      @current_app ||= app_from_basic_authentication
    end
    
    # Return true if an app is currently signed in via API
    # False otherwise
    def app_signed_in?
      !current_app.nil?
    end
    
    # Read the token from the http header and retrieve
    # the matching App
    def app_from_basic_authentication
      returned_app = nil
      authenticate_with_http_basic do |api_token, dontcare|
        returned_app = App.find_by_api_token(api_token)
      end
      returned_app
    end
    
end
