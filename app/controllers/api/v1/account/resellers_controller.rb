class Api::V1::Account::ResellersController < Api::V1::BaseController

  # GET /api/v1/account/resellers
  def index
    @entities = [mocked_reseller]
    logger.info("INSPECT: entities => #{@entities.to_json}")
  end

  # GET /api/v1/account/resellers/rsl-gf784154
  def show
    @entity = mocked_reseller

    if !@entity
      @errors[:id] = ["does not exist"]
      logger.error(@errors)
    end
    logger.info("INSPECT: entity => #{@entity.to_json}")
  end

  protected
    # Scope queries to partners setup with at an instance of the application
    def mocked_reseller
      Reseller.new
    end
end
