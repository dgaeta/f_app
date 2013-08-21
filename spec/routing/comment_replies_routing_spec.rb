require "spec_helper"

describe CommentRepliesController do
  describe "routing" do

    it "routes to #index" do
      get("/comment_replies").should route_to("comment_replies#index")
    end

    it "routes to #new" do
      get("/comment_replies/new").should route_to("comment_replies#new")
    end

    it "routes to #show" do
      get("/comment_replies/1").should route_to("comment_replies#show", :id => "1")
    end

    it "routes to #edit" do
      get("/comment_replies/1/edit").should route_to("comment_replies#edit", :id => "1")
    end

    it "routes to #create" do
      post("/comment_replies").should route_to("comment_replies#create")
    end

    it "routes to #update" do
      put("/comment_replies/1").should route_to("comment_replies#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/comment_replies/1").should route_to("comment_replies#destroy", :id => "1")
    end

  end
end
