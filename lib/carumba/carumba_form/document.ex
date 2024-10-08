defmodule Carumba.CarumbaForm.Document do
  use Ash.Resource, domain: Carumba.CarumbaForm, data_layer: AshPostgres.DataLayer

  alias Carumba.CarumbaForm.Answer
  alias Carumba.CarumbaForm.Form

  postgres do
    table "documents"
    repo Carumba.Repo
  end

  actions do
    defaults [:read, :update]

    create :create do
      argument :form, :string, allow_nil?: false

      primary? true

      change manage_relationship(:form, type: :append_and_remove)
    end
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :form, Form, destination_attribute: :slug, attribute_type: :string
    has_many :answers, Answer
  end
end
