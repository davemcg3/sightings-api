require "rails_helper"

RSpec.describe V1::AuthsController, type: :routing do
  describe "routing" do
    it "routes to #auth" do
      expect(:post => "/v1/auth").to route_to("v1/auths#create")
    end

    it "routes to #register" do
      expect(:post => "/v1/register").to route_to("v1/auths#register")
    end
  end
end
