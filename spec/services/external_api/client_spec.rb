require "rails_helper"

RSpec.describe ExternalApi::Client do
  subject(:client) { described_class.new }

  let(:base_url) { "http://test-external-api.example.com" }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) do
    Faraday.new(url: base_url) do |f|
      f.request :json
      f.response :json
      f.adapter :test, stubs
    end
  end

  before { allow(client).to receive(:connection).and_return(connection) }

  describe "#get" do
    it "returns parsed body on success" do
      stubs.get("/todolists") { [200, { "Content-Type" => "application/json" }, [{ "id" => "1" }].to_json] }
      expect(client.get("/todolists")).to eq([{ "id" => "1" }])
    end

    it "raises NotFoundError on 404" do
      stubs.get("/todolists/999") { [404, {}, "".to_json] }
      expect { client.get("/todolists/999") }.to raise_error(ExternalApi::Client::NotFoundError)
    end

    it "raises ApiError on 500" do
      stubs.get("/todolists") { [500, {}, "Server error".to_json] }
      expect { client.get("/todolists") }.to raise_error(ExternalApi::Client::ApiError)
    end
  end

  describe "#post" do
    it "returns parsed body on 201" do
      stubs.post("/todolists") { [201, { "Content-Type" => "application/json" }, { "id" => "ext-1", "name" => "List" }.to_json] }
      expect(client.post("/todolists", { name: "List" })).to include("id" => "ext-1")
    end

    it "raises UnprocessableError on 422" do
      stubs.post("/todolists") { [422, {}, { "error" => "invalid" }.to_json] }
      expect { client.post("/todolists", {}) }.to raise_error(ExternalApi::Client::UnprocessableError)
    end
  end

  describe "#delete" do
    it "returns nil body on 204" do
      stubs.delete("/todolists/ext-1") { [204, {}, ""] }
      expect { client.delete("/todolists/ext-1") }.not_to raise_error
    end
  end
end
