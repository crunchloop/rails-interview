class AddNotNullToListItemsDescription < ActiveRecord::Migration[7.0]
  def change
    change_column_null :list_items, :description, false
  end
end
