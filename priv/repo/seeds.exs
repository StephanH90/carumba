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

# alias Carumba.CarumbaForm.Form
# alias Carumba.CarumbaForm.Document
# alias Carumba.CarumbaForm.Question

# forms = Ash.read!(Form)

# if length(forms) == 0 do
#   # only load the fixtures if we havent done so yet
#   form = Ash.create!(Form, %{slug: "test-form"})

#   Enum.each(1..10, fn i ->
#     Ash.create!(Question, %{
#       slug: "question-#{i}",
#       type: Enum.random([:text, :textarea, :number]),
#       forms: [form.id],
#       is_required?: Enum.random([true, false])
#     })
#   end)

#   Enum.each(11..50, fn i ->
#     is_hidden = "\"question-#{Enum.random(1..5)}\"|answer #{Enum.random([">", "<", "=="])} 5"

#     Ash.create!(Question, %{
#       slug: "question-#{i}",
#       type: Enum.random([:text, :textarea, :number]),
#       forms: [form.id],
#       is_required?: Enum.random([true, false]),
#       is_hidden: is_hidden
#     })
#   end)

#   document = Ash.create!(Document, %{form: form.id})
# end

alias Carumba.CarumbaForm

q1 = CarumbaForm.create_question!(%{slug: "question-1", configuration: %{min_length: 3, max_length: 10}})
q2 = CarumbaForm.create_question!(%{slug: "question-2", configuration: %{min_length: 10, max_length: 20}})
q3 = CarumbaForm.create_question!(%{slug: "question-3", is_required?: true})

q4 = CarumbaForm.create_question!(%{slug: "question-4", is_required?: true})
q5 = CarumbaForm.create_question!(%{slug: "question-5", is_required?: false})
q6 = CarumbaForm.create_question!(%{slug: "question-6", is_required?: true})

sub_form_1 = CarumbaForm.create_form!(%{slug: "sub-form-1", questions: [q1.slug, q2.slug, q3.slug]})
sub_form_2 = CarumbaForm.create_form!(%{slug: "sub-form-2", questions: [q4.slug, q5.slug, q6.slug]})

form_question_1 = CarumbaForm.create_question!(%{slug: "form-question-1", sub_form: sub_form_1.slug})
form_question_2 = CarumbaForm.create_question!(%{slug: "form-question-2", sub_form: sub_form_2.slug})

main_form = CarumbaForm.create_form!(%{slug: "main-form", questions: [form_question_1.slug, form_question_2.slug]})

document = CarumbaForm.create_document!(main_form.slug)

IO.inspect(document.id, label: "document id")
