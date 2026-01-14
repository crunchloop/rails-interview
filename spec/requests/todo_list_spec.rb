require 'rails_helper'

RSpec.describe 'TodoLists', type: :request do
  describe 'GET /todolists' do
    it 'returns http success and renders index' do
      get todo_lists_path

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET /todolists/new' do
    it 'returns http success and renders new' do
      get new_todo_list_path

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end

  describe 'GET /todolists/:id' do
    let(:todo_list) { create(:todo_list) }

    it 'returns http success and renders show' do
      get todo_list_path(todo_list)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
    end
  end

  describe 'POST /todolists/:id/mark_all_todo_items_as_complete' do
    let(:todo_list) { create(:todo_list) }

    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'enqueues CompleteTodoListItemsJob' do
      expect do
        post mark_all_todo_items_as_complete_todo_list_path(todo_list)
      end.to have_enqueued_job(CompleteTodoListItemsJob)
        .with(todo_list.id)
    end

    it 'redirects to the todo list with notice' do
      post mark_all_todo_items_as_complete_todo_list_path(todo_list)

      expect(response).to redirect_to(todo_list_path(todo_list))
      follow_redirect!

      expect(response.body).to include(
        'Tasks are being marked as complete'
      )
    end
  end
end
