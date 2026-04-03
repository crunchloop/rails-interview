require 'rails_helper'

RSpec.feature "TodoItems", type: :feature do
  let!(:todo_list) { create(:todo_list) }

  describe "index page" do
    it "displays the todo list name" do
      visit "/todolists/#{todo_list.id}/todos"

      expect(page).to have_content(todo_list.name)
    end

    it "displays all todo list items" do
      item1 = create(:todo_item, todo_list: todo_list)
      item2 = create(:todo_item, todo_list: todo_list)

      visit "/todolists/#{todo_list.id}/todos"

      expect(page).to have_content(item1.description)
      expect(page).to have_content(item2.description)
    end

    it "shows completion status for items" do
      create(:todo_item, todo_list: todo_list, completed: true)
      create(:todo_item, todo_list: todo_list, completed: false)

      visit "/todolists/#{todo_list.id}/todos"

      expect(page).to have_content("Completed")
      expect(page).to have_content("Pending")
    end

    it "has a link to add a new todo item" do
      visit "/todolists/#{todo_list.id}/todos"

      expect(page).to have_link("Add Todo")
    end

    it "has edit links for each item" do
      create(:todo_item, todo_list: todo_list)

      visit "/todolists/#{todo_list.id}/todos"

      expect(page).to have_link("Edit")
    end

    it "has delete links for each item" do
      create(:todo_item, todo_list: todo_list)

      visit "/todolists/#{todo_list.id}/todos"

      expect(page).to have_button("Delete")
    end

    it "deletes an item when clicking the delete link" do
      item = create(:todo_item, todo_list: todo_list)

      visit "/todolists/#{todo_list.id}/todos"

      click_button "Delete"

      expect(page).not_to have_content(item.description)
      expect(TodoItem.exists?(item.id)).to be false
    end

    it "shows a complete button for pending items" do
      create(:todo_item, todo_list: todo_list, completed: false)

      visit "/todolists/#{todo_list.id}/todos"

      expect(page).to have_button("Complete")
    end

    it "does not show a complete button for already completed items" do
      create(:todo_item, todo_list: todo_list, completed: true)

      visit "/todolists/#{todo_list.id}/todos"

      expect(page).not_to have_button("Complete")
    end

    it "has a back link to todo lists" do
      visit "/todolists/#{todo_list.id}/todos"

      expect(page).to have_link("Back to Todo Lists", href: "/todolists")
    end
  end

  describe "creating a todo item" do
    it "creates a new item with valid data" do
      description = Faker::Lorem.sentence

      visit "/todolists/#{todo_list.id}/todos/new"

      fill_in "Description", with: description
      click_button "Create Todo Item"

      expect(page).to have_content(description)
    end

    it "shows errors when submitting without a description" do
      visit "/todolists/#{todo_list.id}/todos/new"

      fill_in "Description", with: ""
      click_button "Create Todo Item"

      expect(page).to have_content("can't be blank")
    end

    it "has a back link to the items index" do
      visit "/todolists/#{todo_list.id}/todos/new"

      expect(page).to have_link("Back")
    end
  end

  describe "editing a todo item" do
    let!(:item) { create(:todo_item, todo_list: todo_list) }

    it "updates an item with valid data" do
      new_description = Faker::Lorem.sentence

      visit "/todolists/#{todo_list.id}/todos/#{item.id}/edit"

      fill_in "Description", with: new_description
      click_button "Update Todo Item"

      expect(page).to have_content(new_description)
    end

    it "pre-fills the form with current values" do
      visit "/todolists/#{todo_list.id}/todos/#{item.id}/edit"

      expect(page).to have_field("Description", with: item.description)
      expect(page).to have_unchecked_field("Completed")
    end

    it "can mark an item as completed" do
      visit "/todolists/#{todo_list.id}/todos/#{item.id}/edit"

      check "Completed"
      click_button "Update Todo Item"

      expect(item.reload.completed).to eq(true)
    end

    it "has a back link to the items index" do
      visit "/todolists/#{todo_list.id}/todos/#{item.id}/edit"

      expect(page).to have_link("Back")
    end
  end

  describe "navigating" do
    it "can navigate from items index to new item page" do
      visit "/todolists/#{todo_list.id}/todos"

      click_link "Add Todo"

      expect(current_path).to eq("/todolists/#{todo_list.id}/todos/new")
    end

    it "can navigate from items index to edit item page" do
      item = create(:todo_item, todo_list: todo_list)

      visit "/todolists/#{todo_list.id}/todos"

      click_link "Edit"

      expect(current_path).to eq("/todolists/#{todo_list.id}/todos/#{item.id}/edit")
    end

    it "can navigate back to todo lists from items index" do
      visit "/todolists/#{todo_list.id}/todos"

      click_link "Back to Todo Lists"

      expect(current_path).to eq("/todolists")
    end

    it "can complete a pending item" do
      item = create(:todo_item, todo_list: todo_list, completed: false)

      visit "/todolists/#{todo_list.id}/todos"

      click_button "Complete"

      expect(item.reload.completed).to eq(true)
      expect(current_path).to eq("/todolists/#{todo_list.id}/todos")
    end
  end
end
