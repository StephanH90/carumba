defmodule Carumba.CarumbaForm.QuestionConfiguration do
  defstruct [:min_length, :max_length]
end

defmodule Carumba.CarumbaForm.Question do
  use Ash.Resource, domain: Carumba.CarumbaForm, data_layer: AshPostgres.DataLayer

  alias Carumba.CarumbaForm

  postgres do
    table "questions"
    repo Carumba.Repo

    references do
      reference :sub_form, on_delete: :delete
    end
  end

  attributes do
    # uuid_primary_key :id, writable?: true
    # attribute :slug, :string, writable?: true, allow_nil?: false
    attribute :slug, :string do
      public? true
      writable? true
      primary_key? true
      allow_nil? false
      always_select? true
      generated? false
    end

    attribute :is_required?, :boolean, default: false, allow_nil?: false

    attribute :type, :atom,
      default: :text,
      allow_nil?: false,
      constraints: [one_of: [:text, :textarea, :number, :float, :choice, :multiple_choice, :form]]

    attribute :is_hidden, :string, default: "false", allow_nil?: false

    attribute :configuration, :map,
      constraints: [
        fields: [
          min_length: [type: :integer, constraints: [min: 0]],
          max_length: [type: :integer, constraints: [min: 0]]
        ]
      ],
      default: %{}
  end

  actions do
    defaults [:read]

    read :read_sub_form_questions do
      filter expr(not is_nil(sub_form_id))
    end

    read :read_by_form_and_slug do
      argument :form, :string, allow_nil?: true
      argument :slug, :string, allow_nil?: true

      filter expr(slug == ^arg(:slug) and forms.slug == ^arg(:form))
    end

    update :update do
      accept [:slug, :is_required?, :configuration, :is_hidden]
      primary? true
    end

    create :create do
      accept [:slug, :is_required?, :type, :is_hidden, :configuration]
      primary? true
      argument :forms, {:array, :uuid}, allow_nil?: true
      argument :sub_form, :string, allow_nil?: true

      change manage_relationship(:forms, type: :append_and_remove)
      change manage_relationship(:sub_form, type: :append_and_remove)
    end
  end

  relationships do
    many_to_many :forms, CarumbaForm.Form do
      through CarumbaForm.FormQuestion
      source_attribute_on_join_resource :question_id
      source_attribute :slug
      destination_attribute_on_join_resource :form_id
      destination_attribute :slug
    end

    belongs_to :sub_form, CarumbaForm.Form, destination_attribute: :slug, attribute_type: :string
  end

  preparations do
    prepare build(sort: :slug)
  end

  identities do
    identity :slug, :slug
  end
end
