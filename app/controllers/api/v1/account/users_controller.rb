class Api::V1::Account::UsersController < Api::V1::BaseController
  
  # GET /api/v1/account/users
  def index
    @entities = current_app.users
    
    logger.info("INSPECT: entities => #{@entities}")
  end
  
  # GET /api/v1/account/users/usr-gf784154
  def show
    @entity = current_app.users.find_by_uid(params[:id])
    
    if !@entity
      @errors[:id] = ["does not exist"]
      logger.error(@errors)
    end
    
    logger.info("INSPECT: entity => #{@entity}")
  end
end