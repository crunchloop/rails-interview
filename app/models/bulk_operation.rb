class BulkOperation < ApplicationRecord
  belongs_to :todo_list

  ACTIONS = %w[delete_all mark_all_done].freeze
  STATES = %w[queued running finished failed].freeze

  validates :action, inclusion: { in: ACTIONS }
  validates :state, inclusion: { in: STATES }

  after_create_commit :broadcast!
  after_update_commit :broadcast!

  def progress_percent
    return 0 if total_count.to_i <= 0
    ((processed_count.to_f / total_count.to_f) * 100).clamp(0, 100).round
  end

  def finished?
    state == "finished"
  end

  def failed?
    state == "failed"
  end

  def mark_done_action?
    action == "mark_selected_done" || action == "mark_all_done"
  end

  def broadcast!
    Turbo::StreamsChannel.broadcast_replace_to(
      stream_name,
      target: dom_id,
      partial: "todo_lists/bulk_operation",
      locals: { op: self }
    )
  end

  def stream_name
    "bulk_operations_todo_list_#{todo_list_id}"
  end

  def dom_id
    "bulk_operation_todo_list_#{todo_list_id}"
  end
end
