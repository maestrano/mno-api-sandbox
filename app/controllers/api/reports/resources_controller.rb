class Api::Reports::ResourcesController < ApplicationController
  skip_before_filter :verify_authenticity_token # no need for API endpoints
  before_filter :authenticate_client_app!, except: [:cors_preflight_check]
  before_filter :setup_request
  around_filter :wrap_in_api_transaction
  
  # Return CORS headers
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers
  
  respond_to :json, :json_api
  
  ACCEPTED_RESOURCES = [
    "accounts_summary"
  ];
  
  # GET /api/reports/[group_id]/[entity_type]
  def index
      logger.info("INSPECT: Resource => "+params[:resource])

      #render dummy data by default. All reports are differents so we chose account_summary data schema
      render json: {
                 "to" => Date.today.to_s,
                 "period" => "MONTHLY",
                 "accounts" => []
             }
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
      render text: ''
    end
  end
  
private
  
  # Filter: Capture any internal error and return an API error
  def wrap_in_api_transaction
    respond_to do |format|
      format.any(:json_api, :json) do
        begin
          yield
        rescue Exception => e
          logger.error(e)
          logger.error e.backtrace.join("\n")
          render json: { errors: process_errors(["Internal server error"], 500) }, status: :internal_server_error
        end
      end
    end
  end
  
  # Read the token from the http header and retrieve
  # the matching App
  def authenticate_client_app!
    returned_app = nil
    
    @group_id = params.delete(:group_id)
    logger.info("INSPECT: group_id => #{@group_id}")
    
    if params[:noauth]
      @app_instance = App.first
      return true
    end
    
    authenticate_with_http_basic do |app_id, api_token|
      creds = { id: app_id, key: api_token}
      logger.info("INSPECT: credentials => #{creds}")
      
      @app_instance = App.identify(app_id,api_token,@group_id)
    end
    
    if request.env["HTTP_AUTHORIZATION"].blank?
      logger.info("INSPECT: credentials => none")
    end
    
    unless @app_instance
      render json: { errors: process_errors(["Unauthorized Access"], 401) }, status: :unauthorized
      return false
    end
  
    true
  end
  
  # Load the resource name and fetch the right resource
  # class
  # Return an unknow resource error if resource is not
  # managed by this controller
  def setup_request
    @resource_name = params[:resource]
    @resource_klass_name = "Entity::#{@resource_name}"
    
    begin 
      # Check that resource is managed by this controller
      unless ACCEPTED_RESOURCES.include? @resource_name
        raise NameError
      end

    rescue NameError => e
      logger.info("ressource-name:"+@resource_name)
      render json: { errors: process_errors(["Unknown Resource"], 400) }, status: :bad_request
      return false
    end
    
    true
  end

  
  # Format a collection of errors
  # Expect an array of error descriptions and 
  # a http code (defaulted to "Bad Request")
  def process_errors(errors, http_code = 400, entity = nil)
    err_list = errors.map do |error|
      {
        id: UUID.new.generate,
        status: http_code.to_s,
        code: error.parameterize.gsub(/\-\d+/, ''),
        title: error,
        detail: error
      }
    end
    logger.info("INSPECT: errors => #{err_list.to_json}")
    
    return err_list
  end
  

end
