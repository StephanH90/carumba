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

  Enum.each(1..10, fn i ->
    Ash.create!(Question, %{
      slug: "question-#{i}",
      type: Enum.random([:text, :textarea, :number]),
      forms: [form.id],
      is_required?: Enum.random([true, false])
    })
  end)

  Enum.each(11..50, fn i ->
    is_hidden = "\"question-#{Enum.random(1..5)}\"|answer #{Enum.random([">", "<", "=="])} 5"

    Ash.create!(Question, %{
      slug: "question-#{i}",
      type: Enum.random([:text, :textarea, :number]),
      forms: [form.id],
      is_required?: Enum.random([true, false]),
      is_hidden: is_hidden
    })
  end)

  document = Ash.create!(Document, %{form: form.id})
end
