class Api::V1::Account::GroupsController < Api::V1::BaseController
  
  # GET /api/v1/account/groups
  def index
    @entities = current_app.groups.with_param_filters(params)
    
    logger.info("INSPECT: entities => #{@entities.to_json}")
  end
  
  # GET /api/v1/account/groups/cld-gf784154
  def show
    @entity = current_app.groups.find_by_uid(params[:id])
    
    if !@entity
      @errors[:id] = ["does not exist"]
      logger.error(@errors)
    end
    
    logger.info("INSPECT: entity => #{@entity.to_json}")
  end
  
end