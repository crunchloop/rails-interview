require "rails_helper"

RSpec.describe TodoItem, type: :model do
  it { should belong_to(:todo_list) }

  context "scopes" do
    describe "completed" do
      let(:todo_list) { FactoryBot.create(:todo_list, :with_completed_todo_items)}

      it "should only return completed todo_items" do
        expect(todo_list.todo_items.completed).to eq(todo_list.todo_items)
        expect(todo_list.todo_items.pending).to be_empty
      end
    end

    describe "pending" do
      let(:todo_list) { FactoryBot.create(:todo_list, :with_pending_todo_items)}

      it "should only return pending todo_items" do
        expect(todo_list.todo_items.pending).to eq(todo_list.todo_items)
        expect(todo_list.todo_items.completed).to be_empty
      end
    end
  end

  context "instance methods" do
    describe "#complete!" do
      let(:todo_item) { FactoryBot.create(:todo_item, is_completed: false) }

      it "should set the todo_item to completed" do
        todo_item.complete!
        expect(todo_item.is_completed).to be_truthy
      end
    end

    describe "#undo_complete!" do
      let(:todo_item) { FactoryBot.create(:todo_item, is_completed: true) }

      it "should set the todo_item to pending" do
        todo_item.undo_complete!
        expect(todo_item.is_completed).to be_falsey
      end
    end
  end
end
