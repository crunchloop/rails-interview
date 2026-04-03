require 'rails_helper'

RSpec.describe "Api::TodoLists", type: :request do
  describe "GET /api/todolists" do
    it "returns all todo lists" do
      lists = create_list(:todo_list, 2)

      get "/api/todolists", headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      expect(json.map { |l| l["name"] }).to contain_exactly(*lists.map(&:name))
    end

    it "returns an empty array when there are no lists" do
      get "/api/todolists", headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe "POST /api/todolists" do
    it "creates a todo list with valid params" do
      name = Faker::Lorem.sentence(word_count: 3)

      post "/api/todolists", params: { todo_list: { name: name } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["name"]).to eq(name)
      expect(TodoList.count).to eq(1)
    end

    it "returns errors with invalid params" do
      post "/api/todolists", params: { todo_list: { name: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]["name"]).to be_present
    end

    it "returns errors when name exceeds 150 characters" do
      post "/api/todolists", params: { todo_list: { name: Faker::Lorem.characters(number: 151) } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PUT /api/todolists/:id" do
    let!(:todo_list) { create(:todo_list) }

    it "updates the todo list with valid params" do
      new_name = Faker::Lorem.sentence(word_count: 3)

      put "/api/todolists/#{todo_list.id}", params: { todo_list: { name: new_name } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["name"]).to eq(new_name)
      expect(todo_list.reload.name).to eq(new_name)
    end

    it "returns errors with invalid params" do
      put "/api/todolists/#{todo_list.id}", params: { todo_list: { name: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]["name"]).to be_present
    end
  end

  describe "DELETE /api/todolists/:id" do
    let!(:todo_list) { create(:todo_list) }

    it "deletes the todo list" do
      expect {
        delete "/api/todolists/#{todo_list.id}"
      }.to change(TodoList, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "destroys associated todo items" do
      create(:todo_item, todo_list: todo_list)

      expect {
        delete "/api/todolists/#{todo_list.id}"
      }.to change(TodoItem, :count).by(-1)
    end
  end
end
