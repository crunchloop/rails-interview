require 'rails_helper'

RSpec.describe "Api::TodoItems", type: :request do
  let!(:todo_list) { create(:todo_list) }

  describe "GET /api/todolists/:todo_list_id/todos" do
    it "returns all todo items for the list" do
      items = create_list(:todo_item, 2, todo_list: todo_list)

      get "/api/todolists/#{todo_list.id}/todos", headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      expect(json.map { |i| i["description"] }).to contain_exactly(*items.map(&:description))
    end

    it "returns an empty array when there are no items" do
      get "/api/todolists/#{todo_list.id}/todos", headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe "POST /api/todolists/:todo_list_id/todos" do
    it "creates a todo item with valid params" do
      description = Faker::Lorem.sentence

      post "/api/todolists/#{todo_list.id}/todos",
           params: { todo_item: { description: description } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["description"]).to eq(description)
      expect(json["completed"]).to be false
      expect(TodoItem.count).to eq(1)
    end

    it "associates the item with the correct todo list" do
      post "/api/todolists/#{todo_list.id}/todos",
           params: { todo_item: { description: Faker::Lorem.sentence } }

      expect(TodoItem.last.todo_list).to eq(todo_list)
    end

    it "returns errors with missing description" do
      post "/api/todolists/#{todo_list.id}/todos",
           params: { todo_item: { description: nil } }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]["description"]).to be_present
    end

    it "returns errors when description exceeds 1000 characters" do
      post "/api/todolists/#{todo_list.id}/todos",
           params: { todo_item: { description: Faker::Lorem.characters(number: 1001) } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PUT /api/todolists/:todo_list_id/todos/:id" do
    let!(:todo_item) { create(:todo_item, todo_list: todo_list) }

    it "updates the todo item with valid params" do
      new_description = Faker::Lorem.sentence

      put "/api/todolists/#{todo_list.id}/todos/#{todo_item.id}",
          params: { todo_item: { description: new_description } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["description"]).to eq(new_description)
      expect(todo_item.reload.description).to eq(new_description)
    end

    it "marks the item as completed" do
      put "/api/todolists/#{todo_list.id}/todos/#{todo_item.id}",
          params: { todo_item: { completed: true } }

      expect(response).to have_http_status(:ok)
      expect(todo_item.reload.completed).to be true
    end

    it "returns errors with invalid params" do
      put "/api/todolists/#{todo_list.id}/todos/#{todo_item.id}",
          params: { todo_item: { description: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]["description"]).to be_present
    end
  end

  describe "DELETE /api/todolists/:todo_list_id/todos/:id" do
    let!(:todo_item) { create(:todo_item, todo_list: todo_list) }

    it "deletes the todo item" do
      expect {
        delete "/api/todolists/#{todo_list.id}/todos/#{todo_item.id}"
      }.to change(TodoItem, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
