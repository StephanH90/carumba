defmodule CarumbaWeb.DocumentLiveV2 do
  use CarumbaWeb, :live_view

  alias Carumba.CarumbaForm.{Document, Question}

  def mount(%{"id" => id}, _session, socket) do
    document =
      Ash.get!(Carumba.CarumbaForm.Document, %{id: id}, load: [:answers, form: [:questions]])

    {:ok, assign(socket, document: document)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        :for={question <- @document.form.questions}
        id={["question-", question.id]}
        module={CarumbaWeb.CarumbaForm.InputLive}
        document={@document}
        question={question}
        answer={get_answer_for_question(@document, question)}
      />
    </div>
    """
  end

  def handle_info({:updated_answer, _new_answer}, socket) do
    {:noreply, socket}
  end

  def get_answer_for_question(%Document{answers: answers}, %Question{id: question_id}) do
    Enum.find(answers, fn answer -> answer.question_id == question_id end)
  end
end
