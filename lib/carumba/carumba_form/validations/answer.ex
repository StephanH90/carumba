defmodule Carumba.CarumbaForm.Validations.Answer do
  use Ash.Resource.Validation

  alias Carumba.CarumbaForm.Question

  @impl true
  def validate(changeset, _opts, _ctx) do
    new_value = Ash.Changeset.get_argument_or_attribute(changeset, :value)
    question_slug = Ash.Changeset.get_argument_or_attribute(changeset, :question)

    question = Carumba.CarumbaForm.get_question!(question_slug)

    changeset =
      changeset
      |> validate_is_required?(question, new_value)

    case changeset.valid? do
      true ->
        :ok

      false ->
        changeset.errors
    end
  end

  def validate_is_required?(changeset, %{is_required?: true}, value) when is_nil(value) or value == "" do
    Ash.Changeset.add_error(changeset, field: :value, message: "is required")
  end

  def validate_is_required?(changeset, _question, _value) do
    changeset
  end

  # TODO: reimplement this
  # def validate(%Ash.Changeset{context: %{}} = changeset, opts, ctx) do
  #   # If we haven't preloaded the question in the context we do this now and then rerun this validation function
  #   question =
  #     Ash.get!(Carumba.CarumbaForm.Question, %{
  #       id:
  #         changeset.data.question_id ||
  #           Ash.Changeset.get_argument_or_attribute(changeset, :question)
  #     })

  #   changeset = Ash.Changeset.put_context(changeset, :question, question)

  #   validate(changeset, opts, ctx)
  # end

  # def validate_is_required?(changeset, %Question{is_required?: true}, new_value)
  #      when is_nil(new_value) or new_value == "" do
  #   Ash.Changeset.add_error(changeset, field: :value, message: "is required")
  # end

  # def validate_is_required?(changeset, %Question{is_required?: true}, _new_value), do: changeset
  # def validate_is_required?(changeset, %Question{is_required?: false}, _new_value), do: changeset

  # TODO: Write these for different question types
  def validate_configuration(
        changeset,
        #  todo: in future this would look like this: %Question{type: :string, configuration: %{"min_length" => min_length}},
        %Question{configuration: %{"min_length" => min_length}},
        "min_length",
        new_value
      )
      when is_binary(new_value) do
    if String.length(new_value || "") < min_length do
      Ash.Changeset.add_error(changeset,
        field: :value,
        message: "length of #{String.length(new_value || "")} is too short. min length is #{min_length}"
      )
    else
      changeset
    end
  end

  def validate_configuration(
        changeset,
        #  todo: in future this would look like this: %Question{type: :string, configuration: %{"min_length" => min_length}},
        %Question{configuration: %{"max_length" => max_length}},
        "max_length",
        new_value
      )
      when is_binary(new_value) do
    if String.length(new_value || "") > max_length do
      Ash.Changeset.add_error(changeset,
        field: :value,
        message: "length of #{String.length(new_value || "")} is too long. max length is #{max_length}"
      )
    else
      changeset
    end
  end

  # This needs to be the last method because it is the fallback for all the other configuration keys that are not actually validations
  def validate_configuration(
        changeset,
        _question,
        _other_config_key,
        _new_value
      ) do
    changeset
  end
end
