defmodule Carumba.CarumbaForm.Document do
  use Ash.Resource, domain: Carumba.CarumbaForm, data_layer: AshPostgres.DataLayer

  alias Carumba.CarumbaForm.Answer
  alias Carumba.CarumbaForm.Form
  alias Carumba.CarumbaForm.Question

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

    action :get_answer, :struct do
      constraints instance_of: Answer

      argument :document, :struct, allow_nil?: false, constraints: [instance_of: __MODULE__]
      argument :question, :struct, allow_nil?: false, constraints: [instance_of: Question]

      run fn %{arguments: %{document: document, question: question}}, _ctx ->
        document = Ash.load!(document, [:answers], lazy?: true)

        {
          :ok,
          document.answers
          |> Enum.find(&(&1.question_id == question.id))
        }
      end
    end
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :form, Form
    has_many :answers, Answer
  end
end
