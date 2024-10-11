defmodule Carumba.Types.Fieldset do
  alias Carumba.CarumbaForm

  @enforce_keys [:document, :form]
  defstruct [:document, :form, :fields, :fieldsets]

  @type t() :: %__MODULE__{
          document: CarumbaForm.Document.t(),
          form: CarumbaForm.Form.t(),
          fields: list(Carumba.Types.Field.t())
        }
end
