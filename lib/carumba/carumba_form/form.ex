defmodule Carumba.CarumbaForm.Form do
  use Ash.Resource, domain: Carumba.CarumbaForm, data_layer: AshPostgres.DataLayer

  postgres do
    table "forms"
    repo Carumba.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:slug]

      argument :questions, {:array, :uuid}, allow_nil?: true

      primary? true

      change manage_relationship(:questions, type: :append_and_remove)
    end

    update :update do
      primary? true

      accept [:slug]

      argument :questions, {:array, :uuid}, allow_nil?: true

      require_atomic? false

      change manage_relationship(:questions, type: :append_and_remove)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :slug, :string
  end

  relationships do
    many_to_many :questions, Carumba.CarumbaForm.Question do
      through Carumba.CarumbaForm.FormQuestion
      source_attribute_on_join_resource :form_id
      destination_attribute_on_join_resource :question_id
    end
  end
end
