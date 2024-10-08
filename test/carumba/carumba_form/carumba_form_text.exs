defmodule Carumba.CarumbaForm.CarumbaFormTest do
  use Carumba.DataCase
  use Carumba.Test.Factory

  alias Carumba.CarumbaForm

  describe "save_answer" do
    test "creates an answer" do
      form = insert!(CarumbaForm.Form)
      question = insert!(CarumbaForm.Question, relate: [forms: [form]])
      document = insert!(CarumbaForm.Document, relate: [form: form])

      answer = CarumbaForm.save_answer!(document.id, question.slug, "some value")

      assert answer.value == "some value"
      assert answer.document.id == document.id
    end

    test "updates an answer" do
      form = insert!(CarumbaForm.Form)
      question = insert!(CarumbaForm.Question, relate: [forms: [form]])
      document = insert!(CarumbaForm.Document, relate: [form: form])

      answer = CarumbaForm.save_answer!(document.id, question.slug, "some value")

      assert answer.value == "some value"

      answer = CarumbaForm.save_answer!(document.id, question.slug, "another value")

      assert answer.value == "another value"
    end
  end
end
