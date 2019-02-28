require "rails_helper"

RSpec.describe V1::SubtypesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/v1/subtypes").to route_to("v1/subtypes#index")
    end

    it "routes to #show" do
      expect(:get => "/v1/subtypes/1").to route_to("v1/subtypes#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/v1/subtypes").to route_to("v1/subtypes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/v1/subtypes/1").to route_to("v1/subtypes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/v1/subtypes/1").to route_to("v1/subtypes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/v1/subtypes/1").to route_to("v1/subtypes#destroy", :id => "1")
    end
  end
end
