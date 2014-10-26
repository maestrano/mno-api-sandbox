class Api::V1::Account::UsersController < Api::V1::BaseController
  
  # GET /api/v1/account/users
  def index
    @entities = []
    parent = current_app
    
    if (gid = params.delete(:group_id))
      parent = current_app.groups.find_by_uid(gid)
    end
    
    if parent
      @entities = parent.users.with_param_filters(params)
    end
    
    logger.info("INSPECT: entities => #{@entities.to_json}")
  end
  
  # GET /api/v1/account/users/usr-gf784154
  def show
    @entity = current_app.users.find_by_uid(params[:id])
    
    if !@entity
      @errors[:id] = ["does not exist"]
      logger.error(@errors)
    end
    
    logger.info("INSPECT: entity => #{@entity.to_json}")
  end
end