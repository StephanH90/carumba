defmodule Carumba.CarumbaForm.Calculations.DocumentValidation do
  use Ash.Resource.Calculation

  @impl true
  def load(_query, _opts, _context) do
    [
      form: [questions: [:slug, :is_required?, :configuration]],
      answers: [:value, :is_valid?, :question_id]
    ]
  end

  @impl true
  def calculate(documents = [%Carumba.CarumbaForm.Document{}], _opts, _args) do
    Enum.map(documents, fn document ->
      Enum.map(document.form.questions, fn question ->
        %{
          slug: question.slug,
          is_required?: question.is_required?,
          is_valid?: is_valid?(question, document.answers),
          question: question,
          answer: Enum.find(document.answers, fn answer -> answer.question_id == question.id end),
          temp_value: nil,
          errors: []
        }
      end)
    end)
  end

  defp is_valid?(question, all_answers) do
    !question.is_required? || (question.is_required? and has_valid_answer?(question, all_answers))
  end

  defp has_valid_answer?(question, all_answers) do
    Enum.find(all_answers, false, fn answer ->
      answer.question_id == question.id and answer.is_valid?
    end)
  end
end

# ! FIRST IDEA

# defmodule Carumba.CarumbaForm.Calculations.DocumentValidation do
#   use Ash.Resource.Calculation

#   @impl true
#   def load(_query, _opts, _context) do
#     [form: [questions: [:slug, :is_required]], answers: [:is_valid?, :question_id]]
#   end

#   @impl true
#   def calculate(documents = [%Carumba.CarumbaForm.Document{}], _opts, _args) do
#     Enum.map(documents, fn document ->
#       Enum.reduce(document.form.questions, %{}, fn question, acc ->
#         # require IEx
#         # IEx.pry()
#         Map.put(acc, question.slug, is_valid?(question, document.answers))
#       end)
#     end)
#   end

#   defp is_valid?(question, all_answers) do
#     !question.is_required || (question.is_required and has_valid_answer?(question, all_answers))
#   end

#   defp has_valid_answer?(question, all_answers) do
#     # require IEx
#     # IEx.pry()

#     Enum.find(all_answers, false, fn answer ->
#       answer.question_id == question.id and answer.is_valid?
#     end)
#   end
# end
