require 'spec_helper'

describe "recurring_bills/new" do
  before(:each) do
    assign(:recurring_bill, stub_model(RecurringBill,
      :uid => "MyString",
      :price_cents => 1,
      :currency => "MyString",
      :status => "MyString",
      :period => "MyString",
      :frequency => 1,
      :cycles => 1,
      :group_id => 1
    ).as_new_record)
  end

  it "renders new recurring_bill form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", recurring_bills_path, "post" do
      assert_select "input#recurring_bill_uid[name=?]", "recurring_bill[uid]"
      assert_select "input#recurring_bill_price_cents[name=?]", "recurring_bill[price_cents]"
      assert_select "input#recurring_bill_currency[name=?]", "recurring_bill[currency]"
      assert_select "input#recurring_bill_status[name=?]", "recurring_bill[status]"
      assert_select "input#recurring_bill_period[name=?]", "recurring_bill[period]"
      assert_select "input#recurring_bill_frequency[name=?]", "recurring_bill[frequency]"
      assert_select "input#recurring_bill_cycles[name=?]", "recurring_bill[cycles]"
      assert_select "input#recurring_bill_group_id[name=?]", "recurring_bill[group_id]"
    end
  end
end
