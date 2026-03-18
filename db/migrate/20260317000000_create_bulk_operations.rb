class CreateBulkOperations < ActiveRecord::Migration[7.0]
  def change
    create_table :bulk_operations do |t|
      t.references :todo_list, null: false, foreign_key: true

      t.string :action, null: false # delete_marked, delete_all, mark_selected_done, mark_all_done
      t.string :state, null: false, default: "queued" # queued, running, finished, failed

      t.integer :total_count, null: false, default: 0
      t.integer :processed_count, null: false, default: 0

      t.text :error_message
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end

