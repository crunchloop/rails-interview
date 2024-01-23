require 'sidekiq-scheduler'

class TodoListReminderWorker
  include Sidekiq::Worker

  def perform
    uncompleted_list_ids = TodoList.where(completed: false).pluck(:id)

    return if uncompleted_list_ids.empty?

    AdminUser.find_each do |admin_user|
      TodoListMailer.reminder_email(admin_user.id, uncompleted_list_ids).deliver_now
    end
  end
end
