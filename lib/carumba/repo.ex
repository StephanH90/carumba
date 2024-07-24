defmodule Carumba.Repo do
  use Ecto.Repo,
    otp_app: :carumba,
    adapter: Ecto.Adapters.Postgres
end
