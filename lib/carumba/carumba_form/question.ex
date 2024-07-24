defmodule Carumba.CarumbaForm.Question do
  use Ash.Resource, domain: Carumba.CarumbaForm, data_layer: Ash.DataLayer.Ets

  actions do
    defaults([:read])

    create :create, accept: [:slug]
  end

  attributes do
    uuid_primary_key(:id)

    attribute(:slug, :string)
  end

  relationships do
    many_to_many :forms, Carumba.CarumbaForm.Form do
      through(Carumba.CarumbaForm.FormQuestion)
      source_attribute_on_join_resource(:question_id)
      destination_attribute_on_join_resource(:form_id)
    end
  end
end
