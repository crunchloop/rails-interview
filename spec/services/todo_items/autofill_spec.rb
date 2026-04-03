require 'rails_helper'

RSpec.describe TodoItems::Autofill do
  let(:description) { "Buy milk" }
  let(:todo_list_name) { "Groceries" }
  let(:service) { described_class.new(description, todo_list_name) }

  let(:openai_client) { instance_double(OpenAI::Client) }
  let(:openai_response) do
    {
      "choices" => [
        { "message" => { "content" => "Buy 2 litres of whole milk from the supermarket." } }
      ]
    }
  end

  before do
    allow(OpenAI::Client).to receive(:new).and_return(openai_client)
    allow(openai_client).to receive(:chat).and_return(openai_response)
  end

  describe "#call" do
    it "returns the content from the OpenAI response" do
      result = service.call

      expect(result).to eq("Buy 2 litres of whole milk from the supermarket.")
    end

    it "calls the OpenAI chat API with the correct model and messages" do
      service.call

      expect(openai_client).to have_received(:chat) do |args|
        params = args[:parameters]
        expect(params[:model]).to eq("gpt-3.5-turbo")
        expect(params[:messages]).to include(
          hash_including(role: "system"),
          hash_including(role: "user")
        )
        user_message = params[:messages].find { |m| m[:role] == "user" }
        expect(user_message[:content]).to include(description, todo_list_name)
      end
    end

    it "returns nil when the OpenAI response has no choices" do
      allow(openai_client).to receive(:chat).and_return({})

      expect(service.call).to be_nil
    end
  end
end
