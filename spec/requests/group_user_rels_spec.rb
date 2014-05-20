require 'spec_helper'

describe "GroupUserRels" do
  describe "GET /group_user_rels" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get group_user_rels_path
      response.status.should be(200)
    end
  end
end
