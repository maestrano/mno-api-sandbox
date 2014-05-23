class Api::V1::Billing::BillsController < Api::V1::BaseController
  
  # GET /api/v1/billing/bills
  def index
    @bills = current_app.bills
  end
  
  # GET /api/v1/billing/bills/bill-4s5d3
  def show
    @bill = current_app.bills.find_by_uid(params[:id])
    
    if !@bill
      @errors[:id] = ["does not exist"]
    end
  end
  
  # POST /api/v1/billing/bills
  # Expected attributes
  # => group_id - app_instance id
  # => price_cents - integer
  # => description - string
  # ( => period_start - datetime )
  # ( => period_end - datetime )
  # ( => units - integer/decimal <> 0 )
  # ( => currency - valid three letter code )
  def create
    # Prepare attributes
    whitelist = ['group_id','price_cents','description','units','currency']
    puts params
    attributes = params.select { |k,v| whitelist.include?(k.to_s) }
    attributes.symbolize_keys!
    
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
      render template: 'api/v1/billing/bills/show'
    else
      render template: 'api/v1/base/empty', status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v1/billing/bills/bill-4s5d3
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
      render template: 'api/v1/billing/bills/show'
    else
      render template: 'api/v1/base/empty', status: :unprocessable_entity
    end
  end
end
