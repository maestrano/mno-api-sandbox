class Connec::Api::V2::ResourcesController < ApplicationController
  skip_before_filter :verify_authenticity_token # no need for API endpoints
  before_filter :authenticate_client_app!
  before_filter :setup_request
  around_filter :wrap_in_api_transaction
  
  
  respond_to :json, :json_api
  
  ACCEPTED_RESOURCES = {
    "Account"      => { arity: 'collection' },
    "Company"      => { arity: 'singular' },
    "Invoice"      => { arity: 'collection' },
    "Item"         => { arity: 'collection' },
    "Organization" => { arity: 'collection' },
    "Person"       => { arity: 'collection' },
    "Project"      => { arity: 'collection' },
    "TaxCode"      => { arity: 'collection' },
    "TaxRate"      => { arity: 'collection' },
  }
  
  # GET /api/v2/[group_id]/[entity_type]
  def index
    if singular_resource?
      show
    else
      entities = ConnecEntity.where(group_id: @group_id, entity_name: entities_key)
      
      logger.info("INSPECT: #{entities_key} => #{process_entities(entities).to_json}")
      
      render json: { entities_key => process_entities(entities) }
    end
  end
  
  # GET /api/v2/[group_id]/[entity_type]/:id (collection resource)
  # GET /api/v2/[group_id]/[entity_type] (singular resource)
  def show
    if singular_resource?
      entity = ConnecEntity.where(group_id: @group_id, entity_name: entities_key).first
      entity ||= ConnecEntity.create(group_id: @group_id, entity_name: entities_key)
    else
      entity = ConnecEntity.where(group_id: @group_id, entity_name: entities_key, uid: params[:id]).first
    end
    
    logger.info("INSPECT: #{entities_key} => #{process_entity(entity).to_json}")
    
    if entity
      render json: { entities_key => process_entity(entity) }
    else
      render json: { errors: process_errors(["Resource not found"], 404) }, status: :not_found
    end
  end

  # POST /api/v2/[group_id]/[entity_type] (collection resource only)
  def create
    # Consider request as illegal if performing POST on identifiable resource
    if params[entities_key] && params[entities_key][:id]
      render json: { errors: process_errors(["Creation of resource with id"], 404) }, status: :conflict
      return
    end
    
    # Upsert the entity
    entity = ConnecEntity.new(group_id: @group_id, entity_name: entities_key)
    entity.document = (entity.document || {}).merge(params[entities_key])
    entity.save
    
    logger.info("INSPECT: #{entities_key} => #{process_entity(entity).to_json}")
    
    if entity && entity.errors.empty?
      render json: { entities_key => process_entity(entity.reload) }, status: :created, location: resource_url(entity)
    else
      render json: { errors: process_errors(entity.errors.full_messages, 400, entity) }, status: :bad_request
    end
    
  end

  # PUT /api/v2/[group_id]/[entity_type]/:id (collection resource)
  # PUT /api/v2/[group_id]/[entity_type] (singular resource)
  def update
    if singular_resource?
      entity = ConnecEntity.where(group_id: @group_id, entity_name: entities_key).first
      entity ||= ConnecEntity.create(group_id: @group_id, entity_name: entities_key)
    else
      entity = ConnecEntity.where(group_id: @group_id, entity_name: entities_key, uid: params[:id]).first
    end
    
    entity.document = (entity.document || {}).merge(params[entities_key])
    
    logger.info("INSPECT: #{entities_key} => #{process_entity(entity).to_json}")
    
    if entity
      if entity.save
        render json: { entities_key => process_entity(entity.reload) }
      else
        render json: { errors: process_errors(entity.errors.full_messages, 400, entity) }, status: :bad_request
      end
    else
      render json: { errors: process_errors(["Resource not found"], 404) }, status: :not_found
    end
  end
  
private
  
  # Return whether the resource is a singular resource or not
  def singular_resource?
    @resource_arity.to_s == 'singular'
  end
  
  # Return whether the resource is a collection resource or not
  def collection_resource?
    @resource_arity.to_s == 'collection'
  end
  
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
    @resource_name = params[:resource].singularize.camelize
    @resource_klass_name = "Entity::#{@resource_name}"
    
    begin 
      # Check that resource is managed by this controller
      unless ACCEPTED_RESOURCES[@resource_name]
        raise NameError
      end
      
      # Get resource arity
      @resource_arity = ACCEPTED_RESOURCES[@resource_name][:arity] || 'collection'
      
    rescue NameError => e
      render json: { errors: process_errors(["Unknown Resource"], 400) }, status: :bad_request
      return false
    end
    
    true
  end
  
  # Return the name of an entity based on its class
  def resource_name
    @resource_name
  end
  
  # Basic pluralized form
  def entities_name
    if singular_resource?
      @resource_name
    else
      @resource_name.pluralize
    end
  end
  
  # Return the singular version of entities_key
  def entity_key
    resource_name.underscore.to_sym
  end
  
  # Return the parameter key used in requests
  # and responses to envelope the body
  # Return a symbol
  def entities_key
    entities_name.underscore.to_sym
  end
  
  def process_entities(entities)
    if singular_resource?
      process_entity(entities.first)
    else
      entities.map { |e| process_entity(e) }
    end
  end
  
  def process_entity(entity)
    hash = nil
    if entity
      hash = entity.document
      hash.merge!(id: entity.uid)
      hash.merge!(group_id: @group_id)
      hash.merge!(type: entities_key)
    end
    
    return hash
  end
  
  # Format a collection of errors
  # Expect an array of error descriptions and 
  # a http code (defaulted to "Bad Request")
  def process_errors(errors, http_code = 400, entity = nil)
    errors.map do |error|
      {
        id: UUID.new.generate,
        href: @resource_name ? resource_action_documentation_url : nil,
        status: http_code.to_s,
        code: error.parameterize.gsub(/\-\d+/, ''),
        title: error,
        detail: error
      }
    end
  end
  
  # TODO: put doco_url in Settings
  # Return the full link to the documentation of the
  # action being processed
  def resource_action_documentation_url
    doco_url = "http://maestrano.github.io/connec"
    namespace = entities_name.underscore.gsub('_','-')
    verb = request.method_symbol
    
    # Guess the documentation section
    is_collection = !![/index/,/create/].map{ |re| action_name.match(re) }.compact.first
    if is_collection
      section = "#{entities_name.underscore.gsub('_','-')}-list"
    else
      section = resource_name.underscore.gsub('_','-')
    end
    
    return "#{doco_url}/##{namespace}-#{section}-#{verb}"
  end
  
  # Return the url to a resource
  def resource_url(resource)
    api_v2_resource_url(@group_id, entities_key,resource)
  end
end
