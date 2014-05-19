require 'spec_helper'

describe "apps/index" do
  before(:each) do
    assign(:apps, [
      stub_model(App,
        :api_token => "Api Token"
      ),
      stub_model(App,
        :api_token => "Api Token"
      )
    ])
  end

  it "renders a list of apps" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Api Token".to_s, :count => 2
  end
end
