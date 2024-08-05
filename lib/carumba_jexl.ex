defmodule Carumba.Jexl do
  use Rustler, otp_app: :carumba, crate: "carumba_jexl"

  # When your NIF is loaded, it will override this function.
  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def eval_jexl(_jexl_string, _ctx), do: :erlang.nif_error(:nif_not_loaded)
end
