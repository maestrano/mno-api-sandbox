require 'spec_helper'

describe "bills/index" do
  before(:each) do
    assign(:bills, [
      stub_model(Bill,
        :uid => "Uid",
        :description => "Description",
        :group_id => 1,
        :price_cents => 2,
        :currency => "Currency",
        :units => "9.99"
      ),
      stub_model(Bill,
        :uid => "Uid",
        :description => "Description",
        :group_id => 1,
        :price_cents => 2,
        :currency => "Currency",
        :units => "9.99"
      )
    ])
  end

  it "renders a list of bills" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Uid".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Currency".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
  end
end
