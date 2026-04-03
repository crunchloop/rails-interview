class CompleteAllTodoItemsJob < ApplicationJob
    BATCH_SIZE = 100
    
    queue_as :default

    def perform(todo_list_id)
        todo_list = TodoList.find(todo_list_id)

        todo_list.todo_items.pending.in_batches(of: BATCH_SIZE) do |batch|
            batch.update_all(completed: true)
        end
    end
end