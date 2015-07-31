class Api::V1::Account::BillsController < Api::V1::BaseController

  # GET /api/v1/account/bills
  def index
    @bills = []
    parent = current_app

    if (gid = params.delete(:group_id))
      parent = current_app.groups.find_by_uid(gid)
    end

    if parent
      @bills = parent.bills.with_param_filters(params)
    end

    logger.info("INSPECT: entities => #{@bills.to_json}")
  end

  # GET /api/v1/account/bills/bill-4s5d3
  def show
    if params[:noauth]
      @bill = Bill.find_by_uid(params[:id])
    else
      @bill = current_app.bills.find_by_uid(params[:id])
    end


    if !@bill
      @errors[:id] = ["does not exist"]
      logger.error(@errors)
    end

    logger.info("INSPECT: entity => #{@bill.to_json}")
  end

  # POST /api/v1/account/bills
  # Expected attributes
  # => group_id - app_instance id
  # => price_cents - integer
  # => description - string
  # ( => period_started_at - datetime )
  # ( => period_ended_at - datetime )
  # ( => units - integer/decimal <> 0 )
  # ( => currency - valid three letter code )
  def create
    # Prepare attributes
    whitelist = ['group_id','price_cents','description','units','currency','period_started_at','period_ended_at','third_party']
    attributes = params.select { |k,v| whitelist.include?(k.to_s) }
    attributes.symbolize_keys!

    logger.info("INSPECT: creation attributes => #{attributes}")

    # Find Group
    group = current_app.groups.find_by_uid(attributes.delete(:group_id))

    # Create bill
    if group
      attributes[:group_id] = group.id
      @bill = Bill.create(attributes)
      @errors.merge!(@bill.errors.to_hash)
    else
      @errors[:group_id] = ['does not exist or cannot be charged by your service']
    end

    # Render
    if @errors.empty?
      logger.info("INSPECT: created entity => #{@bill.to_json}")
      render template: 'api/v1/account/bills/show'
    else
      logger.error(@errors)
      render template: 'api/v1/base/empty', status: :bad_request
    end
  end

  # DELETE /api/v1/account/bills/bill-4s5d3
  def destroy
    @bill = current_app.bills.find_by_uid(params[:id])

    if @bill
      @bill.cancel!
      @errors.merge!(@bill.errors.to_hash)
    else
      @errors[:id] = ["does not exist"]
    end

    # Render
    if @errors.empty?
      logger.info("INSPECT: entity => #{@bill.to_json}")
      render template: 'api/v1/account/bills/show'
    else
      logger.error(@errors)
      render template: 'api/v1/base/empty', status: :bad_request
    end
  end
end
