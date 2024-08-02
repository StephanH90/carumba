defmodule Carumba.CarumbaForm.DocumentValidation do
  alias Carumba.CarumbaForm.Document

  def validate_document(%Document{} = document) do
    Enum.map(document.form.questions, fn question ->
      %{
        slug: question.slug,
        is_required?: question.is_required?,
        is_valid?: false,
        question: question,
        answer: Enum.find(document.answers, fn answer -> answer.question_id == question.id end),
        temp_value: nil,
        errors: []
      }
    end)

    # [
    #   %{
    #     slug: "some-question",
    #     # question: %Question{},
    #     # answer: %Answer{},
    #     is_required?: true,
    #     is_valid?: false,
    #     sort: 0,
    #     # for numbers
    #     min: 0,
    #     # for numbers
    #     max: 0,

    #     # For form questions
    #     questions: [],

    #     # For table questions
    #     documents: [
    #       []
    #     ]
    #   }
    # ]
  end
end
