defmodule Carumba.CarumbaForm do
  use Ash.Domain

  resources do
    # resource Carumba.CarumbaForm.Form do
    #   define :get_form, get_by: :id, action: :read
    # end

    # resource Carumba.CarumbaForm.Answer do
    #   define :save_answer, args: [:value, :form, :question], action: :create
    # end

    resource(Carumba.CarumbaForm.Form)

    resource Carumba.CarumbaForm.Answer do
      # define :get_answer, get_by: [:document_id, :question_id]
      define :get_answer
    end

    resource(Carumba.CarumbaForm.Question)
    resource(Carumba.CarumbaForm.FormQuestion)

    resource Carumba.CarumbaForm.Document do
      define :save_answer, args: [:value, :question, :document]
    end
  end
end
