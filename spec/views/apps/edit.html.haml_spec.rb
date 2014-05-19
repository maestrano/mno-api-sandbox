require 'spec_helper'

describe "apps/edit" do
  before(:each) do
    @app = assign(:app, stub_model(App,
      :api_token => "MyString"
    ))
  end

  it "renders the edit app form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", app_path(@app), "post" do
      assert_select "input#app_api_token[name=?]", "app[api_token]"
    end
  end
end
