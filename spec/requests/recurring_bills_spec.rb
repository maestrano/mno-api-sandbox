require 'spec_helper'

describe "RecurringBills" do
  describe "GET /recurring_bills" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get recurring_bills_path
      response.status.should be(200)
    end
  end
end
