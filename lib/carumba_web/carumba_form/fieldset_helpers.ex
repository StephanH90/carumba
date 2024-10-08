defmodule CarumbaWeb.CarumbaForm.FieldsetHelpers do
  @moduledoc """
  These helpers can be used to work with fieldsets and fields in forms.
  """

  alias Carumba.Types.Field
  alias Carumba.Types.Fieldset

  @spec construct_fieldset(Carumba.CarumbaForm.Document.t(), Carumba.CarumbaForm.Form.t()) :: Carumba.Types.Fieldset.t()
  def construct_fieldset(document, form) do
    %Fieldset{
      document: document,
      form: form,
      fields: prepare_fields(document, form),
      fieldsets: prepare_fieldsets(document, form)
    }
  end

  @spec update_answer_in_fieldset(Carumba.Types.Fieldset.t(), Carumba.CarumbaForm.Answer.t()) ::
          Carumba.Types.Fieldset.t()
  def update_answer_in_fieldset(fieldset, updated_answer) do
    cleaned_answers =
      fieldset.document.answers
      |> Enum.reject(&(&1.question_id == updated_answer.question_id))

    new_answers = [updated_answer | cleaned_answers]

    %{fieldset | document: %{fieldset.document | answers: new_answers}}
  end

  defp prepare_fieldsets(document, form) do
    # take all the form questions in the form. for every form question in the form
    # prepare a new fieldset and for that fieldset prepare the fieldsets and the regular questions
    # then prepare the fields for the regular questions
    form.questions
    |> Enum.filter(& &1.sub_form)
    |> Enum.map(fn question -> construct_fieldset(document, question.sub_form) end)
  end

  defp prepare_fields(document, form) do
    # take the qeuestions in the form and choose only the questions which dont have a sub_form.
    # for all of those prepare a %Field{}
    form.questions
    |> Enum.filter(&is_nil(&1.sub_form))
    |> Enum.map(fn question ->
      %Field{
        question: question,
        answer: get_answer_for_document(document, question)
      }
    end)
  end

  defp get_answer_for_document(document, question) do
    document.answers
    |> Enum.find(&(&1.question_id == question.slug))
  end
end
