defmodule Carumba.CarumbaForm.Question do
  use Ash.Resource, domain: Carumba.CarumbaForm, data_layer: AshPostgres.DataLayer

  postgres do
    table "questions"
    repo Carumba.Repo
  end

  actions do
    defaults [:read]

    # create :create, accept: [:slug], primary?: true

    create :create do
      accept [:slug, :is_required]
      primary? true
      argument :forms, {:array, :uuid}, allow_nil?: false

      change manage_relationship(:forms, type: :append_and_remove)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :slug, :string
    attribute :is_required, :boolean, default: false, allow_nil?: false
  end

  relationships do
    many_to_many :forms, Carumba.CarumbaForm.Form do
      through Carumba.CarumbaForm.FormQuestion
      source_attribute_on_join_resource :question_id
      destination_attribute_on_join_resource :form_id
    end
  end
end
