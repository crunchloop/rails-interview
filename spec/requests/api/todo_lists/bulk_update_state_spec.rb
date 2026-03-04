require 'rails_helper'

RSpec.describe 'PATCH /api/todolists/:id/bulk_update_state', type: :request do
  let!(:todo_list) { TodoList.create!(name: 'My List') }

  describe 'with a valid state' do
    it 'returns HTTP 202' do
      patch "/api/todolists/#{todo_list.id}/bulk_update_state",
            params: { state: 'Done' }, as: :json

      expect(response).to have_http_status(:accepted)
    end

    it 'returns a confirmation message' do
      patch "/api/todolists/#{todo_list.id}/bulk_update_state",
            params: { state: 'Done' }, as: :json

      expect(JSON.parse(response.body)).to include('message' => 'Bulk state update enqueued')
    end

    it 'enqueues one UpdateTodoItemStateJob per item' do
      item1 = TodoItem.create!(title: 'Item 1', todo_list: todo_list)
      item2 = TodoItem.create!(title: 'Item 2', todo_list: todo_list)

      expect {
        patch "/api/todolists/#{todo_list.id}/bulk_update_state",
              params: { state: 'Done' }, as: :json
      }.to have_enqueued_job(UpdateTodoItemStateJob).with(item1.id, 'Done')
        .and have_enqueued_job(UpdateTodoItemStateJob).with(item2.id, 'Done')
    end
  end

  describe 'with an invalid state' do
    it 'returns HTTP 422' do
      patch "/api/todolists/#{todo_list.id}/bulk_update_state",
            params: { state: 'InvalidState' }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns an error message' do
      patch "/api/todolists/#{todo_list.id}/bulk_update_state",
            params: { state: 'InvalidState' }, as: :json

      body = JSON.parse(response.body)
      expect(body['error']).to include('Invalid state')
    end

    it 'does not enqueue any jobs' do
      expect {
        patch "/api/todolists/#{todo_list.id}/bulk_update_state",
              params: { state: 'InvalidState' }, as: :json
      }.not_to have_enqueued_job(UpdateTodoItemStateJob)
    end
  end

  describe 'when the TodoList does not exist' do
    it 'returns HTTP 404' do
      patch '/api/todolists/0/bulk_update_state',
            params: { state: 'Done' }, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'returns an error message' do
      patch '/api/todolists/0/bulk_update_state',
            params: { state: 'Done' }, as: :json

      expect(JSON.parse(response.body)).to include('error' => 'TodoList not found')
    end
  end
end
