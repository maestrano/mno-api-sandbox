class Api::V1::Account::ResellerGroupsController < Api::V1::Account::ResellersController

  # GET /api/v1/account/resellers/:reseller_id/groups
  # Action completely mocked. Return all customer groups belonging
  # to the app provider
  def index
    @entities = current_app.groups.with_param_filters(params)
    render 'api/v1/account/groups/index'
  end
end
