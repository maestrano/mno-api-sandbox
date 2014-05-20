require 'spec_helper'

describe "group_user_rels/index" do
  before(:each) do
    assign(:group_user_rels, [
      stub_model(GroupUserRel),
      stub_model(GroupUserRel)
    ])
  end

  it "renders a list of group_user_rels" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
