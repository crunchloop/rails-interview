module Api
  class BulkActionsController < BaseController
    # POST /api/todolists/:todo_list_id/bulk_actions
    def create
      todo_list = current_user.todo_lists.find(params[:todo_list_id])

      action = params.require(:action_name)
      item_ids = params[:item_ids]

      op = BulkOperation.create!(
        todo_list: todo_list,
        action: action,
        state: "queued"
      )

      op.broadcast!
      BulkTodoListItems::KickoffJob.perform_later(
        op_id: op.id,
        item_ids: item_ids
      )

      render json: {
        id: op.id,
        todo_list_id: op.todo_list_id,
        action: op.action,
        state: op.state,
        total_count: op.total_count,
        processed_count: op.processed_count
      }, status: :accepted
    end
  end
end
