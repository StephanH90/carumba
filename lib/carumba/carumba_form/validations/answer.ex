defmodule Carumba.CarumbaForm.Validations.Answer do
  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _opts, _ctx) do
    new_value = Ash.Changeset.get_argument_or_attribute(changeset, :value)

    question_slug =
      Ash.Changeset.get_argument_or_attribute(changeset, :question_id) ||
        Ash.Changeset.get_argument_or_attribute(changeset, :question)

    question = Carumba.CarumbaForm.get_question!(question_slug)

    changeset =
      changeset
      |> validate_is_required?(question, new_value)
      |> validate_value(question, new_value)

    case changeset.valid? do
      true ->
        :ok

      false ->
        error_msg = Enum.map(changeset.errors, fn error -> error.message end) |> Enum.join(". ")
        {:error, field: :value, message: error_msg}
    end
  end

  def validate_is_required?(changeset, %{is_required?: true}, value) when is_nil(value) or value == "" do
    Ash.Changeset.add_error(changeset, field: :value, message: "is required")
  end

  def validate_is_required?(changeset, _question, _value) do
    changeset
  end

  def validate_value(
        changeset,
        %{type: :text, configuration: %{"min_length" => min_length, "max_length" => max_length}},
        new_value
      ) do
    new_value = convert_to_string(new_value)

    if String.length(new_value) > min_length && String.length(new_value) <= max_length do
      changeset
    else
      add_error(changeset, "needs to be longer than #{min_length} and shorter than #{max_length}")
    end
  end

  @spec validate_value(Ash.Changeset.t(), Carumba.CarumbaForm.Question.t(), any()) :: Ash.Changeset.t()
  def validate_value(changeset, %{type: :text, configuration: %{"min_length" => min_length}}, new_value) do
    new_value = convert_to_string(new_value)

    if String.length(new_value) > min_length do
      changeset
    else
      add_error(changeset, "too short")
    end
  end

  def validate_value(changeset, %{type: :text, configuration: %{"max_length" => max_length}}, new_value) do
    new_value = convert_to_string(new_value)

    if String.length(new_value) <= max_length do
      changeset
    else
      add_error(changeset, "too long")
    end
  end

  def validate_value(changeset, %{type: :text}, _new_value) do
    changeset
  end

  defp add_error(changeset, message) do
    Ash.Changeset.add_error(changeset,
      field: :value,
      message: message
    )
  end

  defp convert_to_string(new_value) when is_integer(new_value), do: Integer.to_string(new_value)
  defp convert_to_string(new_value) when is_float(new_value), do: Float.to_string(new_value)
  defp convert_to_string(new_value) when is_binary(new_value), do: new_value
  defp convert_to_string(new_value) when is_nil(new_value), do: ""
end
