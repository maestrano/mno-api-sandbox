class RecurringBillsController < ApplicationController
  # GET /recurring_bills
  # GET /recurring_bills.json
  def index
    @recurring_bills = RecurringBill.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @recurring_bills }
    end
  end

  # GET /recurring_bills/1
  # GET /recurring_bills/1.json
  def show
    @recurring_bill = RecurringBill.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @recurring_bill }
    end
  end

  # GET /recurring_bills/new
  # GET /recurring_bills/new.json
  def new
    @recurring_bill = RecurringBill.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @recurring_bill }
    end
  end

  # GET /recurring_bills/1/edit
  def edit
    @recurring_bill = RecurringBill.find(params[:id])
  end

  # POST /recurring_bills
  # POST /recurring_bills.json
  def create
    @recurring_bill = RecurringBill.new(params[:recurring_bill])

    respond_to do |format|
      if @recurring_bill.save
        format.html { redirect_to @recurring_bill, notice: 'Recurring bill was successfully created.' }
        format.json { render json: @recurring_bill, status: :created, location: @recurring_bill }
      else
        format.html { render action: "new" }
        format.json { render json: @recurring_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /recurring_bills/1
  # PUT /recurring_bills/1.json
  def update
    @recurring_bill = RecurringBill.find(params[:id])

    respond_to do |format|
      if @recurring_bill.update_attributes(params[:recurring_bill])
        format.html { redirect_to @recurring_bill, notice: 'Recurring bill was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @recurring_bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recurring_bills/1
  # DELETE /recurring_bills/1.json
  def destroy
    @recurring_bill = RecurringBill.find(params[:id])
    @recurring_bill.destroy

    respond_to do |format|
      format.html { redirect_to recurring_bills_url }
      format.json { head :no_content }
    end
  end
end
