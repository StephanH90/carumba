defmodule Carumba.Repo.Migrations.AddIsHiddenToQuestion do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:questions) do
      add :is_hidden, :text, null: false, default: "false"
    end
  end

  def down do
    alter table(:questions) do
      remove :is_hidden
    end
  end
end
