require 'spec_helper'

describe "group_user_rels/new" do
  before(:each) do
    assign(:group_user_rel, stub_model(GroupUserRel).as_new_record)
  end

  it "renders new group_user_rel form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", group_user_rels_path, "post" do
    end
  end
end
