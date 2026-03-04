module Sync
  class OutboundTodoItemJob < ApplicationJob
    queue_as :sync

    TAG = "ExternalSync::OutboundTodoItemJob"

    retry_on ExternalApi::Client::ApiError, wait: :polynomially_longer, attempts: 3
    discard_on ExternalApi::Client::NotFoundError do |job, error|
      Rails.logger.tagged(TAG) { Rails.logger.warn("Discarding job — record not found in external API: #{error.message}") }
    end
    discard_on ActiveRecord::RecordNotFound do |job, error|
      Rails.logger.tagged(TAG) { Rails.logger.warn("Discarding job — local record not found: #{error.message}") }
    end

    def perform(todo_item_id, action, external_id: nil)
      service = ExternalApi::TodoItemSync.new

      case action.to_sym
      when :create
        # External API has no POST /todolists/:id/todoitems endpoint.
        # New items are synced to external only when their parent list is first created.
        # For items added to existing lists, sync happens via inbound webhook when
        # the external API adds them (or via a suggested API extension — see NOTES.md).
        Rails.logger.tagged(TAG) do
          Rails.logger.info("Skipping create for item id=#{todo_item_id} — no external endpoint available")
        end

      when :update
        todo_item = TodoItem.find(todo_item_id)
        return skip_no_external_id(todo_item_id) if todo_item.external_id.blank?

        service.update(todo_item)
        todo_item.update_columns(synced_at: Time.current, sync_error: nil)

      when :destroy
        return skip_no_external_id(todo_item_id) if external_id.blank?

        todo_item = TodoItem.find_by(id: todo_item_id) || build_ghost_item(todo_item_id, external_id)
        list_external_id = todo_item.try(:todo_list)&.external_id
        return skip_no_external_id(todo_item_id) if list_external_id.blank?

        service.destroy(list_external_id, external_id)
      end
    rescue ExternalApi::Client::ApiError => e
      record_sync_error!(todo_item_id, e)
      raise
    end

    private

    def skip_no_external_id(todo_item_id)
      Rails.logger.tagged(TAG) { Rails.logger.info("Skipping — no external_id for item id=#{todo_item_id}") }
    end

    def build_ghost_item(todo_item_id, external_id)
      OpenStruct.new(id: todo_item_id, external_id: external_id, todo_list: nil)
    end

    def record_sync_error!(todo_item_id, error)
      TodoItem.where(id: todo_item_id).update_all(sync_error: error.message)
    rescue StandardError
      nil
    end
  end
end
