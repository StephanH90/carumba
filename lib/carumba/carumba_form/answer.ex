defmodule Carumba.CarumbaForm.Answer do
  use Ash.Resource, domain: Carumba.CarumbaForm, data_layer: AshPostgres.DataLayer

  postgres do
    table "answers"
    repo Carumba.Repo
  end

  actions do
    defaults [:read, :destroy]

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
    # validate string_length(:value, min: 5, max: 255)
    validate Carumba.CarumbaForm.Validations.Answer
  end

  attributes do
    uuid_primary_key :id

    attribute :value, :string
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
