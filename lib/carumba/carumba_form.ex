defmodule Carumba.CarumbaForm do
  use Ash.Domain

  resources do
    resource Carumba.CarumbaForm.Form do
      define :read_forms, action: :read
      define :create_form, action: :create
      define :update_form, action: :update
    end

    resource Carumba.CarumbaForm.Answer do
      define :save_answer, action: :save, args: [:document, :question, :value]

      define :create_answer, action: :create, args: [:document, :question, :value]
      define :update_answer, action: :update
      define :get_answer, action: :read, get_by: [:document_id, :question_id]
      define :destroy_answer, action: :destroy
    end

    resource Carumba.CarumbaForm.Question do
      define :create_question, action: :create
      define :read_questions, action: :read
      define :get_question, action: :read, get_by: :slug
    end

    resource Carumba.CarumbaForm.FormQuestion

    resource Carumba.CarumbaForm.Document do
      define :create_document, args: [:form], action: :create
      define :get_document, get_by: :id, action: :read
    end
  end
end
