defmodule Carumba.CarumbaForm.Answer do
  use Ash.Resource, domain: Carumba.CarumbaForm, data_layer: AshPostgres.DataLayer

  postgres do
    table "answers"
    repo Carumba.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:value]

      argument :form, :uuid, allow_nil?: false
      argument :question, :uuid, allow_nil?: false

      change manage_relationship(:form, type: :append_and_remove)
      change manage_relationship(:question, type: :append_and_remove)
    end

    update :update do
      accept [:value]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :value, :string
  end

  relationships do
    belongs_to :form, Carumba.CarumbaForm.Form
    belongs_to :question, Carumba.CarumbaForm.Question
  end
end
