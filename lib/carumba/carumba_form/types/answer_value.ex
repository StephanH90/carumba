defmodule Carumba.CarumbaForm.Types.AnswerValue do
  use Ash.Type

  @moduledoc """
  Custom type for storing answer values as jsonb in the database.
  """

  @impl Ash.Type
  def storage_type(_), do: :jsonb

  @impl Ash.Type
  def cast_input(nil, _), do: {:ok, nil}

  def cast_input(value, _) do
    cast_value(value)
  end

  @impl Ash.Type
  @spec cast_stored(any(), any()) :: :error | {:error, keyword()} | {:ok, any()}
  def cast_stored(nil, _), do: {:ok, nil}

  def cast_stored(value, _) do
    cast_value(value)
  end

  @impl Ash.Type
  def dump_to_native(nil, _), do: {:ok, nil}

  def dump_to_native(value, _) do
    cast_value(value)
  end

  def cast_value(value) do
    with :error <- Ecto.Type.cast(:integer, value),
         :error <- Ecto.Type.cast(:float, value),
         :error <- Ecto.Type.cast(:string, value),
         :error <- Ecto.Type.cast(:map, value),
         :error <- Ecto.Type.cast({:array, :integer}, value),
         :error <- Ecto.Type.cast({:array, :float}, value),
         :error <- Ecto.Type.cast({:array, :string}, value),
         :error <- Ecto.Type.cast({:array, :map}, value) do
      :error
    end
  end
end
