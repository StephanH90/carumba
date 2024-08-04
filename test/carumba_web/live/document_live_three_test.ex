defmodule CarumbaWeb.DocumentLiveThreeTest do
  use CarumbaWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Carumba.CarumbaForm.{Document, Question, Form, Answer}

  test "connected mount", %{conn: conn} do
    form = Ash.create!(Form, %{})

    question =
      Ash.create!(Question, %{
        is_required?: false,
        slug: "question-1",
        forms: [form.id],
        configuration: %{min_length: 5, max_length: 10}
      })

    document = Ash.create!(Document, %{form: form.id})

    {:ok, view, _html} = live(conn, "/document3/#{document.id}")

    assert view
           |> render_blur("save_answer", %{"question_id" => question.id, "value" => "12345"})

    assert view
           |> render_blur("save_answer", %{"question_id" => question.id, "value" => "1234"}) =~
             "length of 4 is too short. min length is 5"

    assert view
           |> render_blur("save_answer", %{
             "question_id" => question.id,
             "value" => "1234567891011"
           }) =~
             "length of 13 is too long. max length is 10"

    view
    |> render_blur("save_answer", %{
      "question_id" => question.id,
      "value" => ""
    })

    assert length(Ash.read!(Answer)) == 0
  end
end
