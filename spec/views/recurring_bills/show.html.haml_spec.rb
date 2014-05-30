require 'spec_helper'

describe "recurring_bills/show" do
  before(:each) do
    @recurring_bill = assign(:recurring_bill, stub_model(RecurringBill,
      :uid => "Uid",
      :price_cents => 1,
      :currency => "Currency",
      :status => "Status",
      :period => "Period",
      :frequency => 2,
      :cycles => 3,
      :group_id => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Uid/)
    rendered.should match(/1/)
    rendered.should match(/Currency/)
    rendered.should match(/Status/)
    rendered.should match(/Period/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
  end
end
