require "rails_helper"

RSpec.describe V1::SightingsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/v1/sightings").to route_to("v1/sightings#index")
    end

    it "routes to #show" do
      expect(:get => "/v1/sightings/1").to route_to("v1/sightings#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/v1/sightings").to route_to("v1/sightings#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/v1/sightings/1").to route_to("v1/sightings#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/v1/sightings/1").to route_to("v1/sightings#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/v1/sightings/1").to route_to("v1/sightings#destroy", :id => "1")
    end
  end
end
