defmodule Carumba.Types.Field do
  @moduledoc """
  A struct which represents a combination of a question and an answer.
  """
  alias Carumba.CarumbaForm.Answer
  alias Carumba.CarumbaForm.Form

  @enforce_keys [:question, :answer]
  defstruct [:question, :answer, is_valid?: false]

  @type t() :: %__MODULE__{
          question: Form.t(),
          answer: Answer.t(),
          is_valid?: boolean()
        }
end
