class TodoListMailer < ApplicationMailer
  def items_processing_finished(user, todo_list)
    @todo_list = todo_list

    mail(
      to: user.email,
      subject: 'Your tasks were completed'
    )
  end
end
