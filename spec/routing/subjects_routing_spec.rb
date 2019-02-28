require "rails_helper"

RSpec.describe V1::SubjectsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/v1/subjects").to route_to("v1/subjects#index")
    end

    it "routes to #show" do
      expect(:get => "/v1/subjects/1").to route_to("v1/subjects#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/v1/subjects").to route_to("v1/subjects#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/v1/subjects/1").to route_to("v1/subjects#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/v1/subjects/1").to route_to("v1/subjects#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/v1/subjects/1").to route_to("v1/subjects#destroy", :id => "1")
    end
  end
end
