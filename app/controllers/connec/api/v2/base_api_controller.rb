class Connec::Api::V2::BaseApiController < ApplicationController
  before_filter :authenticate_client_app!
  
  respond_to :json

  # GET /connec/api/v2/[group_id]/[entity_type]
  def index
    entities = ConnecEntity.where(group_id: @group_id, entity_name: self.class.entity_class_name)
    entities_json = entities.map { |e| entity_hash(e.document) }
    
    logger.info("INSPECT: entities => #{entities_json.to_json}")
    
    render json: {metadata: { count: entities.size }, entities:  entities_json }
  end
  
  # GET /connec/api/v2/[group_id]/[entity_type]/:id
  def show
    entity = ConnecEntity.where(group_id: @group_id, entity_name: self.class.entity_class_name, uid: params[:id]).first
    
    logger.info("INSPECT: entity => #{entity_hash(entity).to_json}")
    
    render json: { entity: entity_hash(entity) }
  end

  # POST /connec/api/v2/[group_id]/[entity_type]
  def create
    # Upsert the entity
    if params[:entity] && params[:entity][:id]
      entity = ConnecEntity.where(group_id: @group_id, entity_name: self.class.entity_class_name, uid: params[:entity][:id]).first
    end
    entity ||= ConnecEntity.new(group_id: @group_id, entity_name: self.class.entity_class_name)
    
    entity.document = (entity.document || {}).merge(params[:entity])
    entity.save
    
    logger.info("INSPECT: entity => #{entity_hash(entity).to_json}")
    
    render json: { entity: entity_hash(entity) }
  end

  # PUT /connec/api/v2/[group_id]/[entity_type]/:id
  def update
    params[:entity] ||= {}
    params[:entity].merge(id: params[:id])
    
    create
  end
  
  private
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
        head :unauthorized
        return false
      end
    
      true
    end
    
    def self.generate_controllers
      # Should dynamically get the list of entities
      [
        "Account", "Company", "Invoice", "Item", "Organization", "Person", "Project","TaxCode","TaxRate"
      ].each do |entity_class_name|
        controller_class = Class.new(Connec::Api::V2::BaseApiController)
        controller_name = "#{entity_class_name.pluralize}Controller"
        unless Connec::Api::V2.const_defined?(controller_name)
          const = Connec::Api::V2.const_set(controller_name, controller_class)
          const.define_singleton_method(:entity_class_name) { entity_class_name }
        end
      end
    end
    
    
    def entity_hash(entity)
      hash = nil
      if entity
        hash = (entity.document || {})
        hash.merge!(id: entity.uid)
        hash.merge!(group_id: @group_id)
        hash.merge!(errors: entity.errors.full_messages) if entity.errors.any?
      end
    
      return hash
    end
end