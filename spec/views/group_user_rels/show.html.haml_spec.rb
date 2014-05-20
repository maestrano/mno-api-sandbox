require 'spec_helper'

describe "group_user_rels/show" do
  before(:each) do
    @group_user_rel = assign(:group_user_rel, stub_model(GroupUserRel))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
