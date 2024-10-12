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

    fieldset = %{fieldset | document: %{fieldset.document | answers: new_answers}}

    fieldset
    |> update_answer_in_fields(updated_answer)
  end

  def remove_answer_in_fieldset(fieldset, removed_answer) do
    cleaned_answers =
      fieldset.document.answers
      |> Enum.reject(&(&1.question_id == removed_answer.question_id))

    fieldset = %{fieldset | document: %{fieldset.document | answers: cleaned_answers}}

    fieldset
    |> remove_answer_in_fields(removed_answer)
  end

  defp update_answer_in_fields(fieldset, updated_answer) do
    # Update the fields with the new answer if the question matches
    updated_fields =
      Enum.map(fieldset.fields, fn field ->
        if field.question.slug == updated_answer.question_id do
          # Update the field with the new answer
          %{field | answer: updated_answer}
        else
          field
        end
      end)

    # Recursively update nested fieldsets
    updated_fieldsets =
      Enum.map(fieldset.fieldsets, fn nested_fieldset ->
        update_answer_in_fields(nested_fieldset, updated_answer)
      end)

    # Return the updated fieldset with updated fields and nested fieldsets
    %{fieldset | fields: updated_fields, fieldsets: updated_fieldsets}
  end

  defp remove_answer_in_fields(fieldset, removed_answer) do
    updated_fields =
      Enum.map(fieldset.fields, fn field ->
        if field.question.slug == removed_answer.question_id do
          # Update the field with the new answer
          %{field | answer: nil}
        else
          field
        end
      end)

    # Recursively update nested fieldsets
    updated_fieldsets =
      Enum.map(fieldset.fieldsets, fn nested_fieldset ->
        remove_answer_in_fields(nested_fieldset, removed_answer)
      end)

    # Return the updated fieldset with updated fields and nested fieldsets
    %{fieldset | fields: updated_fields, fieldsets: updated_fieldsets}
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

  @doc """
  A fieldset is valid if all of its fields and all the fields of all the nested fieldsets (recursively) are valid
  """
  defp perform_validation(fieldset) do
    all_fields_valid? = Enum.map(fieldset.fields, &validate/1) |> Enum.all?()
    all_fieldsets_valid? = Enum.map(fieldset.fieldsets, &validate/1) |> Enum.all?()

    all_fields_valid? and all_fieldsets_valid?
  end

  def validate(%Field{} = field) do
    if field.question.is_required? do
      not is_nil(field.answer)
    else
      true
    end
  end

  def validate(%Fieldset{} = fieldset) do
    perform_validation(fieldset)
  end
end
