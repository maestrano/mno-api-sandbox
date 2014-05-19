require 'spec_helper'

describe "bills/edit" do
  before(:each) do
    @bill = assign(:bill, stub_model(Bill,
      :uid => "MyString",
      :description => "MyString",
      :group_id => 1,
      :price_cents => 1,
      :currency => "MyString",
      :units => "9.99"
    ))
  end

  it "renders the edit bill form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", bill_path(@bill), "post" do
      assert_select "input#bill_uid[name=?]", "bill[uid]"
      assert_select "input#bill_description[name=?]", "bill[description]"
      assert_select "input#bill_group_id[name=?]", "bill[group_id]"
      assert_select "input#bill_price_cents[name=?]", "bill[price_cents]"
      assert_select "input#bill_currency[name=?]", "bill[currency]"
      assert_select "input#bill_units[name=?]", "bill[units]"
    end
  end
end
