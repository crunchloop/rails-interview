module Sync
  class InboundSyncJob < ApplicationJob
    queue_as :sync

    TAG = "ExternalSync::InboundSyncJob"

    def perform(payload)
      event         = payload["event"]
      resource_type = payload["resource_type"]
      data          = payload["data"]

      Rails.logger.tagged(TAG) { Rails.logger.info("Processing event=#{event} resource_type=#{resource_type}") }

      case resource_type
      when "todo_list"  then sync_todo_list(event, data)
      when "todo_item"  then sync_todo_item(event, data)
      else
        Rails.logger.tagged(TAG) { Rails.logger.warn("Unknown resource_type=#{resource_type}, skipping") }
      end
    end

    private

    # ── TodoList ──────────────────────────────────────────────────────────────

    def sync_todo_list(event, data)
      case event
      when "created", "updated" then upsert_todo_list(data)
      when "deleted"            then delete_todo_list(data)
      else
        Rails.logger.tagged(TAG) { Rails.logger.warn("Unknown event=#{event} for todo_list, skipping") }
      end
    end

    def upsert_todo_list(data)
      external_id = data["id"]
      source_id   = data["source_id"]

      todo_list = find_todo_list(external_id, source_id)

      if todo_list && local_is_newer?(todo_list, data)
        Rails.logger.tagged(TAG) { Rails.logger.info("Skipping list id=#{todo_list.id} — local is newer") }
        return
      end

      TodoList.skip_sync do
        attrs = { name: data["name"], external_id: external_id, synced_at: Time.current, sync_error: nil }
        todo_list = todo_list ? todo_list.tap { |l| l.update!(attrs) } : TodoList.create!(attrs)
        Rails.logger.tagged(TAG) { Rails.logger.info("Upserted list id=#{todo_list.id} external_id=#{external_id}") }

        sync_items_for_list(todo_list, data.fetch("items", []))
      end
    end

    def delete_todo_list(data)
      todo_list = find_todo_list(data["id"], data["source_id"])
      return unless todo_list

      TodoList.skip_sync { todo_list.destroy! }
      Rails.logger.tagged(TAG) { Rails.logger.info("Deleted list id=#{todo_list.id} external_id=#{data['id']}") }
    end

    def find_todo_list(external_id, source_id)
      TodoList.find_by(external_id: external_id) ||
        (source_id.present? ? TodoList.find_by(id: source_id.to_i) : nil)
    end

    # ── TodoItem ──────────────────────────────────────────────────────────────

    def sync_todo_item(event, data)
      case event
      when "created", "updated" then upsert_todo_item(data)
      when "deleted"            then delete_todo_item(data)
      else
        Rails.logger.tagged(TAG) { Rails.logger.warn("Unknown event=#{event} for todo_item, skipping") }
      end
    end

    def upsert_todo_item(data)
      external_id      = data["id"]
      source_id        = data["source_id"]
      list_external_id = data["todo_list_id"]

      todo_list = TodoList.find_by(external_id: list_external_id)
      unless todo_list
        Rails.logger.tagged(TAG) { Rails.logger.warn("TodoList not found for item external_id=#{external_id}, skipping") }
        return
      end

      todo_item = find_todo_item(external_id, source_id)

      if todo_item && local_is_newer?(todo_item, data)
        Rails.logger.tagged(TAG) { Rails.logger.info("Skipping item id=#{todo_item.id} — local is newer") }
        return
      end

      TodoItem.skip_sync do
        attrs = {
          description: data["description"],
          state:       data["completed"] ? "Done" : "Ready for start",
          external_id: external_id,
          synced_at:   Time.current,
          sync_error:  nil,
          todo_list:   todo_list
        }
        if todo_item
          todo_item.update!(attrs.except(:todo_list))
        else
          todo_item = TodoItem.create!(attrs.merge(title: data["description"].presence || "Untitled"))
        end
        Rails.logger.tagged(TAG) { Rails.logger.info("Upserted item id=#{todo_item.id} external_id=#{external_id}") }
      end
    end

    def delete_todo_item(data)
      todo_item = find_todo_item(data["id"], data["source_id"])
      return unless todo_item

      TodoItem.skip_sync { todo_item.destroy! }
      Rails.logger.tagged(TAG) { Rails.logger.info("Deleted item id=#{todo_item.id} external_id=#{data['id']}") }
    end

    def find_todo_item(external_id, source_id)
      TodoItem.find_by(external_id: external_id) ||
        (source_id.present? ? TodoItem.find_by(id: source_id.to_i) : nil)
    end

    # ── Items nested in TodoList payload ─────────────────────────────────────

    def sync_items_for_list(todo_list, items_data)
      incoming_external_ids = items_data.filter_map { |d| d["id"] }

      items_data.each { |item_data| upsert_todo_item(item_data.merge("todo_list_id" => todo_list.external_id)) }

      # Remove items no longer present in external
      todo_list.todo_items
               .where.not(external_id: nil)
               .where.not(external_id: incoming_external_ids)
               .each do |stale_item|
        TodoItem.skip_sync { stale_item.destroy! }
        Rails.logger.tagged(TAG) { Rails.logger.info("Removed stale item id=#{stale_item.id}") }
      end
    end

    # ── Helpers ───────────────────────────────────────────────────────────────

    def local_is_newer?(record, data)
      return false if record.updated_at.nil? || data["updated_at"].nil?

      record.updated_at > Time.parse(data["updated_at"])
    end
  end
end
