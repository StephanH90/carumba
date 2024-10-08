defmodule Carumba.Repo.Migrations.ChangeForeignKey do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:questions) do
      modify :slug, :text, null: false
    end

    create unique_index(:answers, [:document_id, :question_id],
             name: "answers_document_question_index"
           )
  end

  def down do
    drop_if_exists unique_index(:answers, [:document_id, :question_id],
                     name: "answers_document_question_index"
                   )

    alter table(:questions) do
      modify :slug, :text, null: true
    end
  end
end
