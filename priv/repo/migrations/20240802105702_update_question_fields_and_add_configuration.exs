defmodule Carumba.Repo.Migrations.UpdateQuestionFieldsAndAddConfiguration do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:questions) do
      add :configuration, :map
    end
  end

  def down do
    alter table(:questions) do
      remove :configuration
    end
  end
end
