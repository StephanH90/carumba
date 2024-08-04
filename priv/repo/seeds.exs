# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Carumba.Repo.insert!(%Carumba.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Carumba.CarumbaForm.Form
alias Carumba.CarumbaForm.Document
alias Carumba.CarumbaForm.Question

forms = Ash.read!(Form)

if length(forms) == 0 do
  # only load the fixtures if we havent done so yet
  form = Ash.create!(Form, %{slug: "test-form"})

  question_1 = Ash.create!(Question, %{slug: "a-question", type: :text, forms: [form.id], is_required?: false})
  question_2 = Ash.create!(Question, %{slug: "another-question", type: :text, forms: [form.id], configuration: %{min_length: 5, max_length: 10}})
  question_2 = Ash.create!(Question, %{slug: "a-third-question", type: :number, forms: [form.id], is_required?: true})

  document = Ash.create!(Document, %{form: form.id})
end
