# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::TodoListsController do
  render_views

  describe 'GET index' do
    let!(:todo_list) { create(:todo_list) }

    context 'when format is HTML' do
      it 'raises a routing error' do
        expect do
          get :index
        end.to raise_error(ActionController::UnknownFormat)
      end
    end

    context 'when format is JSON' do
      it 'returns a success code' do
        get :index, format: :json

        expect(response.status).to eq(200)
      end

      it 'includes todo list records' do
        get :index, format: :json

        todo_lists = JSON.parse(response.body)

        aggregate_failures 'includes the id and name' do
          expect(todo_lists.count).to eq(1)
          expect(todo_lists[0].keys).to match_array(%w[id name])
          expect(todo_lists[0]['id']).to eq(todo_list.id)
          expect(todo_lists[0]['name']).to eq(todo_list.name)
        end
      end
    end
  end

  describe 'PATCH complete_all' do
    let!(:todo_list) { create(:todo_list) }
    let(:complete_all_request) { patch :complete_all, params: { id: todo_list.id }, format: :json }

    it 'returns a success code' do
      complete_all_request

      expect(response.status).to eq(204)
    end

    it 'enqueues a worker' do
      complete_all_request

      expect(CompleteAllItemsWorker).to have_enqueued_sidekiq_job(todo_list.id.to_s)
    end

    it 'returns an error if the todo list is not found' do
      patch :complete_all, params: { id: -1 }, format: :json

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Todo list not found' })
    end
  end
end
