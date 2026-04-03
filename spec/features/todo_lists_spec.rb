require 'rails_helper'

RSpec.feature "TodoLists", type: :feature do
  describe "index page" do
    it "displays all todo lists" do
      list1 = create(:todo_list)
      list2 = create(:todo_list)

      visit "/todolists"

      expect(page).to have_content(list1.name)
      expect(page).to have_content(list2.name)
    end

    it "has a link to add a new todo list" do
      visit "/todolists"

      expect(page).to have_link("Add Todo List")
    end

    it "has edit links for each todo list" do
      create(:todo_list)

      visit "/todolists"

      expect(page).to have_link("Edit")
    end

    it "has delete links for each todo list" do
      create(:todo_list)

      visit "/todolists"

      expect(page).to have_button("Delete")
    end

    it "deletes a todo list when clicking the delete button" do
      list = create(:todo_list)

      visit "/todolists"

      click_button "Delete"

      expect(page).not_to have_content(list.name)
      expect(TodoList.exists?(list.id)).to be false
    end
  end

  describe "creating a todo list" do
    it "creates a new todo list with valid data" do
      name = Faker::Lorem.sentence(word_count: 3)

      visit "/todolists/new"

      fill_in "Name", with: name
      click_button "Create Todo List"

      expect(page).to have_content(name)
      expect(current_path).to eq("/todolists")
    end

    it "shows errors when submitting without a name" do
      visit "/todolists/new"

      fill_in "Name", with: ""
      click_button "Create Todo List"

      expect(page).to have_content("can't be blank")
    end

    it "has a back link to the index" do
      visit "/todolists/new"

      expect(page).to have_link("Back", href: "/todolists")
    end
  end

  describe "editing a todo list" do
    it "updates a todo list with valid data" do
      list = create(:todo_list)
      new_name = Faker::Lorem.sentence(word_count: 3)

      visit "/todolists/#{list.id}/edit"

      fill_in "Name", with: new_name
      click_button "Update Todo List"

      expect(page).to have_content(new_name)
      expect(current_path).to eq("/todolists")
    end

    it "pre-fills the form with the current name" do
      list = create(:todo_list)

      visit "/todolists/#{list.id}/edit"

      expect(page).to have_field("Name", with: list.name)
    end

    it "has a back link to the index" do
      list = create(:todo_list)

      visit "/todolists/#{list.id}/edit"

      expect(page).to have_link("Back", href: "/todolists")
    end
  end

  describe "navigating from index" do
    it "can navigate to new todo list page" do
      visit "/todolists"

      click_link "Add Todo List"

      expect(current_path).to eq("/todolists/new")
    end

    it "can navigate to edit todo list page" do
      list = create(:todo_list)

      visit "/todolists"

      click_link "Edit"

      expect(current_path).to eq("/todolists/#{list.id}/edit")
    end
  end

  describe "complete all action" do
    let!(:list) { create(:todo_list) }

    it "shows the Complete All button when there are pending items" do
      create(:todo_item, todo_list: list, completed: false)

      visit "/todolists"

      expect(page).to have_button("Complete All")
    end

    it "enqueues a job and shows a notice when Complete All is clicked" do
      create(:todo_item, todo_list: list, completed: false)

      visit "/todolists"

      expect { click_button "Complete All" }.to have_enqueued_job(CompleteAllTodoItemsJob)

      expect(current_path).to eq("/todolists")
      expect(page).to have_content("will be marked as completed")
    end
  end
end