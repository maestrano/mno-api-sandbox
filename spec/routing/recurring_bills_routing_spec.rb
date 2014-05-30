require "spec_helper"

describe RecurringBillsController do
  describe "routing" do

    it "routes to #index" do
      get("/recurring_bills").should route_to("recurring_bills#index")
    end

    it "routes to #new" do
      get("/recurring_bills/new").should route_to("recurring_bills#new")
    end

    it "routes to #show" do
      get("/recurring_bills/1").should route_to("recurring_bills#show", :id => "1")
    end

    it "routes to #edit" do
      get("/recurring_bills/1/edit").should route_to("recurring_bills#edit", :id => "1")
    end

    it "routes to #create" do
      post("/recurring_bills").should route_to("recurring_bills#create")
    end

    it "routes to #update" do
      put("/recurring_bills/1").should route_to("recurring_bills#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/recurring_bills/1").should route_to("recurring_bills#destroy", :id => "1")
    end

  end
end
