# This controller is inherited by all API controllers
# It is used to automatically retrieve the current_app
# corresponding to the cloud service contacting us
#
# The controller uses http basic authentication and
# retrieves the app based on its api token
class Api::V1::BaseController < ApplicationController
  before_filter :authenticate_app!
  around_filter :prepare_and_handle_error

  # Return CORS access
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers
  
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
        logger.error(@errors)
        render template: 'api/v1/base/empty', status: :unauthorized
      end
    end
    
    # Filter
    # Prepare the @errors variables
    # Catch errors and deliver standard system error
    # using the classical API response format
    def prepare_and_handle_error
      @errors = {}
      logger.info("INSPECT: current_app => #{current_app.to_json}")
      begin
        yield
      rescue Exception => e
        logger.error(e)
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
      return App.first if params[:noauth]
      authenticate_with_http_basic do |app_id, api_token|
        creds = { id: app_id, key: api_token}
        logger.info("INSPECT: credentials => #{creds}")
        returned_app = App.find_by_uid_and_api_token(app_id,api_token)
      end
      
      if request.env["HTTP_AUTHORIZATION"].blank?
        logger.info("INSPECT: credentials => none")
      end
      
      returned_app
    end

    # For all responses in this controller, return the CORS access control headers.
    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

    # If this is a preflight OPTIONS request, then short-circuit the
    # request, return only the necessary headers and return an empty text/plain.
    def cors_preflight_check
      if request.method == :options
        cors_set_access_control_headers
        render :text => '', :content_type => 'text/plain'
      end
    end
    
end
