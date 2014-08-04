class Api::V1::Account::GroupsController < Api::V1::BaseController
  
  # GET /api/v1/account/groups
  def index
    @entities = current_app.groups
  end
  
  # GET /api/v1/account/groups/cld-gf784154
  def show
    @entity = current_app.groups.find_by_uid(params[:id])
    
    if !@entity
      @errors[:id] = ["does not exist"]
    end
  end
  
end