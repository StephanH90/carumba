defmodule Carumba.AnswerValue do
  use Ash.Type

  @moduledoc """
  Custom type for storing answer values as jsonb in the database.
  """

  @impl Ash.Type
  def storage_type(_), do: :jsonb

  @impl Ash.Type
  def cast_input(nil, _), do: {:ok, nil}

  def cast_input(value, _) do
    cast_value(value)
  end

  @impl Ash.Type
  def cast_stored(nil, _), do: {:ok, nil}

  def cast_stored(value, _) do
    cast_value(value)
  end

  @impl Ash.Type
  def dump_to_native(nil, _), do: {:ok, nil}

  def dump_to_native(value, _) do
    cast_value(value)
  end

  def cast_value(value) do
    with :error <- Ecto.Type.cast(:integer, value),
         :error <- Ecto.Type.cast(:float, value),
         :error <- Ecto.Type.cast(:string, value),
         :error <- Ecto.Type.cast(:map, value),
         :error <- Ecto.Type.cast({:array, :integer}, value),
         :error <- Ecto.Type.cast({:array, :float}, value),
         :error <- Ecto.Type.cast({:array, :string}, value),
         :error <- Ecto.Type.cast({:array, :map}, value) do
      :error
    end
  end
end

defmodule Carumba.CarumbaForm.Answer do
  use Ash.Resource, domain: Carumba.CarumbaForm, data_layer: AshPostgres.DataLayer

  postgres do
    table "answers"
    repo Carumba.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :value, :carumba_value
  end

  actions do
    defaults [:destroy, :read]

    read :get_answer do
      get_by [:document_id, :question_id]
      get? true
    end

    create :create do
      primary? true
      accept [:value]

      argument :document, :uuid, allow_nil?: false
      argument :question, :uuid, allow_nil?: false

      change manage_relationship(:document, type: :append_and_remove)
      change manage_relationship(:question, type: :append_and_remove)
    end

    update :update do
      accept [:value]
      primary? true
      require_atomic? false
    end
  end

  validations do
    validate Carumba.CarumbaForm.Validations.Answer
  end

  relationships do
    belongs_to :document, Carumba.CarumbaForm.Document
    belongs_to :question, Carumba.CarumbaForm.Question
  end

  calculations do
    # TODO: REMOVE
    calculate :is_valid?,
              :boolean,
              expr(
                not question.is_required? or (question.is_required? and value != "") or
                  (question.is_required? and value != nil)
              )
  end
end
