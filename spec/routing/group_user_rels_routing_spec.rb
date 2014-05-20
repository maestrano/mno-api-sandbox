require "spec_helper"

describe GroupUserRelsController do
  describe "routing" do

    it "routes to #index" do
      get("/group_user_rels").should route_to("group_user_rels#index")
    end

    it "routes to #new" do
      get("/group_user_rels/new").should route_to("group_user_rels#new")
    end

    it "routes to #show" do
      get("/group_user_rels/1").should route_to("group_user_rels#show", :id => "1")
    end

    it "routes to #edit" do
      get("/group_user_rels/1/edit").should route_to("group_user_rels#edit", :id => "1")
    end

    it "routes to #create" do
      post("/group_user_rels").should route_to("group_user_rels#create")
    end

    it "routes to #update" do
      put("/group_user_rels/1").should route_to("group_user_rels#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/group_user_rels/1").should route_to("group_user_rels#destroy", :id => "1")
    end

  end
end
