module ExternalApi
  class TodoItemSync
    TAG = "ExternalSync::TodoItem"

    def initialize(client: Client.instance)
      @client = client
    end

    def update(todo_item)
      raise ArgumentError, "TodoItem id=#{todo_item.id} has no external_id" if todo_item.external_id.blank?
      raise ArgumentError, "TodoList id=#{todo_item.todo_list_id} has no external_id" if todo_item.todo_list.external_id.blank?

      path = "/todolists/#{todo_item.todo_list.external_id}/todoitems/#{todo_item.external_id}"
      data = @client.patch(path, { description: todo_item.description, completed: todo_item.done? })
      Rails.logger.tagged(TAG) { Rails.logger.info("Updated item id=#{todo_item.id} external_id=#{todo_item.external_id}") }
      data
    end

    def destroy(list_external_id, item_external_id)
      path = "/todolists/#{list_external_id}/todoitems/#{item_external_id}"
      @client.delete(path)
      Rails.logger.tagged(TAG) { Rails.logger.info("Deleted item external_id=#{item_external_id} from list external_id=#{list_external_id}") }
    end
  end
end
