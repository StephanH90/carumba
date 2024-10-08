defmodule Carumba.CarumbaForm.Validations.AnswerTest do
  use Carumba.DataCase
  use Carumba.Test.Factory

  alias Carumba.CarumbaForm

  test "validate_is_required?/2" do
    form = insert!(CarumbaForm.Form)
    question = insert!(CarumbaForm.Question, relate: [forms: [form]])
    document = insert!(CarumbaForm.Document, relate: [form: form])

    answer = CarumbaForm.save_answer!(document.id, question.slug, "some value")

    assert answer.value == "some value"
    assert answer.document.id == document.id

    answer = CarumbaForm.save_answer(document.id, question.slug, nil)
  end
end
