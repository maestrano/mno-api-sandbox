require 'spec_helper'

describe "bills/show" do
  before(:each) do
    @bill = assign(:bill, stub_model(Bill,
      :uid => "Uid",
      :description => "Description",
      :group_id => 1,
      :price_cents => 2,
      :currency => "Currency",
      :units => "9.99"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Uid/)
    rendered.should match(/Description/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Currency/)
    rendered.should match(/9.99/)
  end
end
