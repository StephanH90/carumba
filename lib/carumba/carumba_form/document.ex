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

    action :save_answer do
      argument :value, :string
      argument :question, :uuid, allow_nil?: false
      argument :document, :uuid, allow_nil?: false

      run fn input, ctx ->
        require IEx
        IEx.pry()

        document = Ash.read!(Carumba.CarumbaForm.Document, %{id: input.arguments.document})
        question = Ash.read!(Carumba.CarumbaForm.Question, %{id: input.arguments.question})

        case Carumba.CarumbaForm.get_answer(%{
               document_id: document.id,
               question_id: question.id
             }) do
          {:ok, answer} ->
            # we already have an answer and need to update it instead
            :ok

          {:error, _} ->
            # we need to create a new answer
            :ok
        end

        # This is a placeholder
        {:ok, "Hello: #{input.arguments.name}"}
      end
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
    calculate :fieldsets,
              :map,
              {Carumba.CarumbaForm.Calculations.DocumentValidation, keys: [:answers]}
  end
end
