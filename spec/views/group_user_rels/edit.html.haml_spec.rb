require 'spec_helper'

describe "group_user_rels/edit" do
  before(:each) do
    @group_user_rel = assign(:group_user_rel, stub_model(GroupUserRel))
  end

  it "renders the edit group_user_rel form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", group_user_rel_path(@group_user_rel), "post" do
    end
  end
end
