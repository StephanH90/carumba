defmodule Carumba.CarumbaForm.FormQuestion do
  use Ash.Resource, domain: Carumba.CarumbaForm, data_layer: AshPostgres.DataLayer

  postgres do
    table "form_questions"
    repo Carumba.Repo

    references do
      reference :form, on_delete: :delete
      reference :question, on_delete: :delete
    end
  end

  relationships do
    belongs_to :form, Carumba.CarumbaForm.Form,
      primary_key?: true,
      allow_nil?: false,
      destination_attribute: :slug,
      attribute_type: :string

    belongs_to :question, Carumba.CarumbaForm.Question,
      primary_key?: true,
      allow_nil?: false,
      destination_attribute: :slug,
      attribute_type: :string
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
