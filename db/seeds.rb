lists_with_items = {
  "Setup Rails Application" => [
    { title: "Install Ruby", description: "Install the required Ruby version via rbenv or rvm", state: "Done", start_date: 10.days.ago, end_date: 9.days.ago },
    { title: "Create new Rails app", description: "Run `rails new` with the desired flags and options", state: "Done", start_date: 9.days.ago, end_date: 8.days.ago },
    { title: "Configure Gemfile", description: "Add required gems and run bundle install", state: "Done", start_date: 8.days.ago, end_date: 7.days.ago },
    { title: "Setup environment variables", description: "Create .env file and configure credentials", state: "In progress", start_date: 7.days.ago, end_date: Date.today + 1 },
    { title: "Configure Puma", description: "Tune worker count and thread settings for production", state: "Ready for start", start_date: Date.today, end_date: Date.today + 2 }
  ],
  "Setup Docker PG database" => [
    { title: "Write docker-compose.yml", description: "Define postgres service, volume, and port mapping", state: "Done", start_date: 5.days.ago, end_date: 4.days.ago },
    { title: "Pull postgres image", description: "Run `docker compose pull` to download the postgres image", state: "Done", start_date: 4.days.ago, end_date: 4.days.ago },
    { title: "Start database container", description: "Run `docker compose up -d` to start the container", state: "Done", start_date: 3.days.ago, end_date: 3.days.ago },
    { title: "Verify connection", description: "Connect with psql or a GUI client to verify the DB is reachable", state: "In progress", start_date: 2.days.ago, end_date: Date.today },
    { title: "Add healthcheck to compose", description: "Add a healthcheck so Rails waits for Postgres to be ready", state: "Ready for start", start_date: Date.today, end_date: Date.today + 1 }
  ],
  "Create todo_lists table" => [
    { title: "Generate migration", description: "Run `rails g migration CreateTodoLists name:string`", state: "Done", start_date: 14.days.ago, end_date: 14.days.ago },
    { title: "Review migration file", description: "Check null constraints and default values", state: "Done", start_date: 14.days.ago, end_date: 13.days.ago },
    { title: "Run db:migrate", description: "Apply the migration to development and test databases", state: "Done", start_date: 13.days.ago, end_date: 13.days.ago },
    { title: "Add database index", description: "Index the name column for faster lookups if needed", state: "Ready for start", start_date: Date.today, end_date: Date.today + 3 }
  ],
  "Create TodoList model" => [
    { title: "Generate model", description: "Run `rails g model TodoList` and verify the generated files", state: "Done", start_date: 13.days.ago, end_date: 12.days.ago },
    { title: "Add validations", description: "Validate presence and uniqueness of name", state: "Done", start_date: 12.days.ago, end_date: 11.days.ago },
    { title: "Write model specs", description: "Cover validations and associations with RSpec", state: "In progress", start_date: 5.days.ago, end_date: Date.today + 1 },
    { title: "Add has_many :todo_items", description: "Define the association and add dependent: :destroy", state: "Done", start_date: 11.days.ago, end_date: 10.days.ago }
  ],
  "Create TodoList controller" => [
    { title: "Generate controller", description: "Run `rails g controller TodoLists` for the base scaffold", state: "Done", start_date: 10.days.ago, end_date: 9.days.ago },
    { title: "Implement index action", description: "List all todo lists with pagination via kaminari", state: "Done", start_date: 9.days.ago, end_date: 8.days.ago },
    { title: "Implement show action", description: "Display a single list with its items", state: "Done", start_date: 8.days.ago, end_date: 7.days.ago },
    { title: "Implement create action", description: "Handle form submission and Turbo Stream response", state: "Done", start_date: 7.days.ago, end_date: 6.days.ago },
    { title: "Implement update action", description: "Handle inline edit and respond with Turbo Stream", state: "In progress", start_date: 3.days.ago, end_date: Date.today + 2 },
    { title: "Implement destroy action", description: "Delete list and redirect with a flash notice", state: "Ready for start", start_date: Date.today + 1, end_date: Date.today + 3 },
    { title: "Write request specs", description: "Cover all CRUD actions with RSpec request specs", state: "Ready for start", start_date: Date.today + 2, end_date: Date.today + 5 }
  ]
}

lists_with_items.each do |list_name, items|
  list = TodoList.find_or_create_by!(name: list_name)
  items.each do |attrs|
    list.todo_items.find_or_create_by!(title: attrs[:title]) do |item|
      item.assign_attributes(attrs.except(:title))
    end
  end
end

puts "Seeded #{TodoList.count} todo lists with #{TodoItem.count} items."
