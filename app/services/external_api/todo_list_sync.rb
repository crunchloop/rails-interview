module ExternalApi
  class TodoListSync
    TAG = "ExternalSync::TodoList"

    def initialize(client: Client.instance)
      @client = client
    end

    def create(todo_list)
      payload = {
        source_id: todo_list.id.to_s,
        name: todo_list.name,
        items: todo_list.todo_items.map { |item| item_payload(item) }
      }

      data = @client.post("/todolists", payload)
      Rails.logger.tagged(TAG) { Rails.logger.info("Created list id=#{todo_list.id} → external_id=#{data['id']}") }
      data
    end

    def update(todo_list)
      raise ArgumentError, "TodoList id=#{todo_list.id} has no external_id" if todo_list.external_id.blank?

      data = @client.patch("/todolists/#{todo_list.external_id}", { name: todo_list.name })
      Rails.logger.tagged(TAG) { Rails.logger.info("Updated list id=#{todo_list.id} external_id=#{todo_list.external_id}") }
      data
    end

    def destroy(external_id)
      @client.delete("/todolists/#{external_id}")
      Rails.logger.tagged(TAG) { Rails.logger.info("Deleted list external_id=#{external_id}") }
    end

    private

    def item_payload(item)
      { source_id: item.id.to_s, description: item.description, completed: item.done? }
    end
  end
end
