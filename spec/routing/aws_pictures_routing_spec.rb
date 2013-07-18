require "spec_helper"

describe AwsPicturesController do
  describe "routing" do

    it "routes to #index" do
      get("/aws_pictures").should route_to("aws_pictures#index")
    end

    it "routes to #new" do
      get("/aws_pictures/new").should route_to("aws_pictures#new")
    end

    it "routes to #show" do
      get("/aws_pictures/1").should route_to("aws_pictures#show", :id => "1")
    end

    it "routes to #edit" do
      get("/aws_pictures/1/edit").should route_to("aws_pictures#edit", :id => "1")
    end

    it "routes to #create" do
      post("/aws_pictures").should route_to("aws_pictures#create")
    end

    it "routes to #update" do
      put("/aws_pictures/1").should route_to("aws_pictures#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/aws_pictures/1").should route_to("aws_pictures#destroy", :id => "1")
    end

  end
end
