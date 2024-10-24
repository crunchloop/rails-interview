require 'rails_helper'

RSpec.describe TodoListsController, type: :controller do
  let!(:todo_list) { create(:todo_list) }  
  # FactoryBot para crear una TodoList de prueba

  describe "GET #index" do
    it "asigna todas las todo_lists a @todo_lists" do
      get :index
      expect(assigns(:todo_lists)).to eq([todo_list])
    end

    it "devuelve una respuesta exitosa" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #show" do
    it "asigna la todo_list solicitada a @todo_list" do
      get :show, params: { id: todo_list.id }
      expect(assigns(:todo_list)).to eq(todo_list)
    end

    it "devuelve una respuesta exitosa" do
      get :show, params: { id: todo_list.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #complete" do
    it "coloca el trabajo CompleteTodoListJob en la cola" do
      expect {
        post :complete, params: { id: todo_list.id }
      }.to have_enqueued_job(CompleteTodoListJob).with(todo_list.id)
    end

    it "redirecciona al index de todo_lists con un mensaje de éxito" do
      post :complete, params: { id: todo_list.id }
      expect(response).to redirect_to(todo_lists_path)
      expect(flash[:notice]).to eq('Task is being complete in background.')
    end
  end
end
