class TodoListMailer < ApplicationMailer
  def reminder_email(admin_user_id, uncompleted_list_ids)
    @admin_user = AdminUser.find(admin_user_id)
    @uncompleted_lists = TodoList.where(id: uncompleted_list_ids)

    mail(to: @admin_user.email, subject: 'Reminder: Uncompleted Todo Lists')
  end
end
