class Api::V1::Account::RecurringBillsController < Api::V1::BaseController
  
  # GET /api/v1/account/bills
  def index
    @recurring_bills = current_app.recurring_bills
    
    logger.info("INSPECT: entities => #{@recurring_bills}")
  end
  
  # GET /api/v1/account/bills/bill-4s5d3
  def show
    @recurring_bill = current_app.recurring_bills.find_by_uid(params[:id])
    
    if !@recurring_bill
      @errors[:id] = ["does not exist"]
      logger.error(@errors)
    end
    
    logger.info("INSPECT: entity => #{@recurring_bill}")
  end
  
  # POST /api/v1/account/bills
  # Expected attributes
  # => group_id - app_instance id
  # => price_cents - integer
  # => description - string
  # ( => period - string [Day, Week, SemiMonth, Month, Year] default: Month )
  # ( => frequency - integer - default: 1)
  # ( => cycles - integer - default: nil)
  # ( => start_date - integer - default: now)
  # ( => currency - valid three letter code - default: AUD)
  def create
    # Prepare attributes
    whitelist = ['group_id','period','frequency','cycles','price_cents','description','currency','start_date','initial_cents']
    attributes = params.select { |k,v| whitelist.include?(k.to_s) }
    attributes.symbolize_keys!
    
    logger.info("INSPECT: creation attributes => #{attributes}")
    
    # Find Group
    group = current_app.groups.find_by_uid(attributes.delete(:group_id))
    
    # Create bill
    if group
      attributes[:group_id] = group.id
      @recurring_bill = RecurringBill.create(attributes)
      @errors.merge!(@recurring_bill.errors.to_hash)
    else
      @errors[:group_id] = ['does not exist or cannot be charged by your service']
    end
    
    # Render
    if @errors.empty?
      @recurring_bill.setup!
      logger.info("INSPECT: created entity => #{@recurring_bill}")
      render template: 'api/v1/account/recurring_bills/show'
    else
      logger.error(@errors)
      render template: 'api/v1/base/empty', status: :bad_request
    end
  end
  
  # DELETE /api/v1/account/bills/bill-4s5d3
  def destroy
    @recurring_bill = current_app.recurring_bills.find_by_uid(params[:id])
    
    if @recurring_bill
      @recurring_bill.cancel!
      @errors.merge!(@recurring_bill.errors.to_hash)
    else
      @errors[:id] = ["does not exist"]
    end
    
    # Render
    if @errors.empty?
      logger.info("INSPECT: entity => #{@recurring_bill}")
      render template: 'api/v1/account/recurring_bills/show'
    else
      logger.error(@errors)
      render template: 'api/v1/base/empty', status: :bad_request
    end
  end
end
