defmodule Carumba.CarumbaForm do
  use Ash.Domain

  resources do
    resource Carumba.CarumbaForm.Form do
      define :get_form, get_by: :id, action: :read
    end

    resource Carumba.CarumbaForm.Answer do
      define :save_answer, args: [:value, :form, :question], action: :create
    end

    resource(Carumba.CarumbaForm.Question)
    resource(Carumba.CarumbaForm.FormQuestion)
    resource(Carumba.CarumbaForm.Document)
  end
end
