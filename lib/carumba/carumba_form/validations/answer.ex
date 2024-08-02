defmodule Carumba.CarumbaForm.Validations.Answer do
  use Ash.Resource.Validation

  alias Carumba.CarumbaForm.Question

  @impl true
  def validate(changeset, _opts, _ctx) do
    # require IEx
    # IEx.pry()

    question =
      Ash.get!(Carumba.CarumbaForm.Question, %{
        id:
          changeset.data.question_id ||
            Ash.Changeset.get_argument_or_attribute(changeset, :question)
      })

    new_value = Ash.Changeset.get_argument_or_attribute(changeset, :value)

    changeset = validate_is_required?(changeset, question, new_value)

    if question.is_required? do
      # If the question is required we only run the rest of the validations if an actual value is present
      if changeset.valid? do
        changeset =
          Enum.reduce(Map.keys(question.configuration || %{}), changeset, fn key, changeset ->
            validate_configuration(changeset, question, key, new_value)
          end)

        if changeset.valid? do
          :ok
        else
          {:error, changeset}
        end
      else
        # Otherwise we just return the changeset with the "is required" error
        {:error, changeset}
      end
    else
      # this || %{} is not necessary for new questions. TODO: REMOVE
      changeset =
        Enum.reduce(Map.keys(question.configuration || %{}), changeset, fn key, changeset ->
          validate_configuration(changeset, question, key, new_value)
        end)

      if changeset.valid? do
        :ok
      else
        {:error, changeset}
      end
    end
  end

  defp validate_is_required?(changeset, %Question{is_required?: true}, new_value)
       when is_nil(new_value) do
    Ash.Changeset.add_error(changeset, field: :value, message: "is required")
  end

  defp validate_is_required?(changeset, %Question{is_required?: true}, new_value)
       when new_value == "" do
    Ash.Changeset.add_error(changeset, field: :value, message: "is required")
  end

  defp validate_is_required?(changeset, %Question{is_required?: true}, _new_value), do: changeset
  defp validate_is_required?(changeset, %Question{is_required?: false}, _new_value), do: changeset

  # TODO: Write these for different question types
  defp validate_configuration(
         changeset,
         #  todo: in future this would look like this: %Question{type: :string, configuration: %{"min_length" => min_length}},
         %Question{configuration: %{"min_length" => min_length}},
         "min_length",
         new_value
       ) do
    if String.length(new_value) < min_length do
      Ash.Changeset.add_error(changeset,
        field: :value,
        message: "length of #{String.length(new_value)} is too short. min length is #{min_length}"
      )
    else
      changeset
    end
  end

  defp validate_configuration(
         changeset,
         #  todo: in future this would look like this: %Question{type: :string, configuration: %{"min_length" => min_length}},
         %Question{configuration: %{"max_length" => max_length}},
         "max_length",
         new_value
       ) do
    if String.length(new_value) > max_length do
      Ash.Changeset.add_error(changeset,
        field: :value,
        message: "length of #{String.length(new_value)} is too long. max length is #{max_length}"
      )
    else
      changeset
    end
  end

  # This needs to be the last method because it is the fallback for all the other configuration keys that are not actually validations
  defp validate_configuration(
         changeset,
         _question,
         _other_config_key,
         _new_value
       ) do
    changeset
  end
end
