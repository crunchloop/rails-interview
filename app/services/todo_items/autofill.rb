module TodoItems
    class Autofill
        def initialize(description, todo_list_name)
            @description = description
            @todo_list_name = todo_list_name
        end

        def call
            response = OpenAI::Client.new.chat(
                parameters: {
                    model: "gpt-3.5-turbo",
                    messages: [
                        {
                            role: "system",
                            content: I18n.t('prompts.autofill.system')
                        },
                        {
                            role: "user",
                            content: I18n.t('prompts.autofill.user', description: @description, todolist: @todo_list_name)
                        }
                    ],
                    temperature: 0.7
                }
            )
            response.dig("choices", 0, "message", "content")
        end
    end
end