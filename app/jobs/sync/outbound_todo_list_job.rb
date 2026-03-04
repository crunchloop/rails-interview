module Sync
  class OutboundTodoListJob < ApplicationJob
    queue_as :sync

    TAG = "ExternalSync::OutboundTodoListJob"

    retry_on ExternalApi::Client::ApiError, wait: :polynomially_longer, attempts: 3
    discard_on ExternalApi::Client::NotFoundError do |job, error|
      Rails.logger.tagged(TAG) { Rails.logger.warn("Discarding job — record not found in external API: #{error.message}") }
    end
    discard_on ActiveRecord::RecordNotFound do |job, error|
      Rails.logger.tagged(TAG) { Rails.logger.warn("Discarding job — local record not found: #{error.message}") }
    end

    def perform(todo_list_id, action, external_id: nil)
      service = ExternalApi::TodoListSync.new

      case action.to_sym
      when :create
        todo_list = TodoList.find(todo_list_id)
        data = service.create(todo_list)
        sync_external_ids!(todo_list, data)

      when :update
        todo_list = TodoList.find(todo_list_id)
        return skip_no_external_id(todo_list_id) if todo_list.external_id.blank?

        service.update(todo_list)
        todo_list.update_columns(synced_at: Time.current, sync_error: nil)

      when :destroy
        return skip_no_external_id(todo_list_id) if external_id.blank?

        service.destroy(external_id)
      end
    rescue ExternalApi::Client::ApiError => e
      record_sync_error!(todo_list_id, e)
      raise
    end

    private

    def sync_external_ids!(todo_list, data)
      TodoList.skip_sync do
        todo_list.update_columns(external_id: data["id"], synced_at: Time.current, sync_error: nil)

        data.fetch("items", []).each do |item_data|
          next if item_data["source_id"].blank?

          TodoItem.where(id: item_data["source_id"].to_i)
                  .update_all(external_id: item_data["id"], synced_at: Time.current, sync_error: nil)
        end
      end

      Rails.logger.tagged(TAG) { Rails.logger.info("Synced external_ids for list id=#{todo_list.id}") }
    end

    def skip_no_external_id(todo_list_id)
      Rails.logger.tagged(TAG) { Rails.logger.info("Skipping — no external_id for list id=#{todo_list_id}") }
    end

    def record_sync_error!(todo_list_id, error)
      TodoList.where(id: todo_list_id).update_all(sync_error: error.message)
    rescue StandardError
      nil
    end
  end
end
