defmodule Carumba.CarumbaForm do
  use Ash.Domain

  resources do
    resource(Carumba.CarumbaForm.Form)
    resource(Carumba.CarumbaForm.Question)
    resource(Carumba.CarumbaForm.FormQuestion)
  end
end
