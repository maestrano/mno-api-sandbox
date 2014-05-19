require 'spec_helper'

describe "apps/new" do
  before(:each) do
    assign(:app, stub_model(App,
      :api_token => "MyString"
    ).as_new_record)
  end

  it "renders new app form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", apps_path, "post" do
      assert_select "input#app_api_token[name=?]", "app[api_token]"
    end
  end
end
