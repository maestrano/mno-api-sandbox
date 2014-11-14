class Connec::Api::V2::CompanyController < Connec::Api::V2::BaseApiController
  
  # GET /v1/:group_id/company
  def index
    logger.info("INSPECT: entity => #{entity_hash(group_company).to_json}")
    
    render json: { entity: entity_hash(group_company) }
  end

  # GET /v1/:group_id/company
  def show
    logger.info("INSPECT: entity => #{entity_hash(group_company).to_json}")
    
    render json: { entity: entity_hash(group_company) }
  end
  
  # POST /v1/:group_id/company
  def create
    # Upsert the entity
    group_company.document = (group_company.document || {}).merge(params[:entity])
    group_company.save
    
    logger.info("INSPECT: entity => #{entity_hash(group_company).to_json}")
    
    render json: { entity: entity_hash(group_company) }
  end
  
  # PUT /v1/:group_id/company
  def update
    # Merge id
    params[:entity] ||= {}
    params[:entity].merge(id: params[:id])
    
    # Call create
    create
  end
  
  #==========================================================
  # Private
  #==========================================================
  private
    def group_company
      @group_company = begin
        company = ConnecEntity.where(entity_name: 'company',group_id: @group_id).first
        unless company
          company = ConnecEntity.create(entity_name: 'company',group_id: @group_id, document: {currency: 'USD'})
        end
        company
      end
    end
end