require 'rails_helper'

RSpec.describe "Checkouts", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/checkouts/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/checkouts/create"
      expect(response).to have_http_status(:success)
    end
  end

end
