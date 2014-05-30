require 'spec_helper'

describe "recurring_bills/index" do
  before(:each) do
    assign(:recurring_bills, [
      stub_model(RecurringBill,
        :uid => "Uid",
        :price_cents => 1,
        :currency => "Currency",
        :status => "Status",
        :period => "Period",
        :frequency => 2,
        :cycles => 3,
        :group_id => 4
      ),
      stub_model(RecurringBill,
        :uid => "Uid",
        :price_cents => 1,
        :currency => "Currency",
        :status => "Status",
        :period => "Period",
        :frequency => 2,
        :cycles => 3,
        :group_id => 4
      )
    ])
  end

  it "renders a list of recurring_bills" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Uid".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Currency".to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
    assert_select "tr>td", :text => "Period".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
