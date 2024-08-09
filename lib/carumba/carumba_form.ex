defmodule Carumba.CarumbaForm do
  use Ash.Domain

  resources do
    resource(Carumba.CarumbaForm.Form)

    resource Carumba.CarumbaForm.Answer

    resource(Carumba.CarumbaForm.Question)
    resource(Carumba.CarumbaForm.FormQuestion)

    resource Carumba.CarumbaForm.Document do
      define :get_answer, args: [:document, :question]
    end
  end
end
