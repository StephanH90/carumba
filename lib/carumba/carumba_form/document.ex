defmodule Carumba.CarumbaForm.Document do
  use Ash.Resource, domain: Carumba.CarumbaForm, data_layer: AshPostgres.DataLayer

  postgres do
    table "documents"
    repo Carumba.Repo
  end

  actions do
    defaults [:read, :update]

    create :create do
      argument :form, :uuid

      primary? true

      change manage_relationship(:form, type: :append_and_remove)
    end
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :form, Carumba.CarumbaForm.Form
    has_many :answers, Carumba.CarumbaForm.Answer
  end

  calculations do
    calculate :validations,
              :map,
              {Carumba.CarumbaForm.Calculations.DocumentValidation, keys: [:answers]}
  end
end
