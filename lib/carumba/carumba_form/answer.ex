defmodule Carumba.CarumbaForm.Answer do
  use Ash.Resource, domain: Carumba.CarumbaForm, data_layer: AshPostgres.DataLayer

  alias Carumba.CarumbaForm

  postgres do
    table "answers"
    repo Carumba.Repo
  end

  attributes do
    uuid_primary_key :id, writable?: true

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
      argument :question, :string, allow_nil?: false

      change manage_relationship(:document, type: :append_and_remove)
      change manage_relationship(:question, type: :append_and_remove)

      # validate Carumba.CarumbaForm.Validations.Answer
    end

    update :update do
      accept [:value]
      primary? true
      require_atomic? false
      # validate Carumba.CarumbaForm.Validations.Answer
    end

    action :save, :struct do
      constraints instance_of: __MODULE__
      argument :document, :uuid, allow_nil?: false
      argument :question, :string, allow_nil?: false
      argument :value, :carumba_value, allow_nil?: false

      run fn input, ctx ->
        document_uuid = Ash.Changeset.get_argument(input, :document)
        question_slug = Ash.Changeset.get_argument(input, :question)
        value = Ash.Changeset.get_argument_or_attribute(input, :value)

        case CarumbaForm.get_answer(document_uuid, question_slug) do
          {:ok, answer} ->
            if (is_binary(value) and value == "") or (is_boolean(value) and not value) or
                 (is_list(value) and length(value) == 0) do
              CarumbaForm.destroy_answer(answer)
            else
              CarumbaForm.update_answer(answer, %{value: value})
            end

          {:error, _} ->
            CarumbaForm.create_answer(document_uuid, question_slug, value)
        end
      end
    end
  end

  relationships do
    belongs_to :document, Carumba.CarumbaForm.Document
    belongs_to :question, Carumba.CarumbaForm.Question, destination_attribute: :slug, attribute_type: :string
  end

  identities do
    identity :document_question, [:document_id, :question_id]
  end
end
