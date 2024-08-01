defmodule CarumbaWeb.FormLive.Show do
  use CarumbaWeb, :live_view

  alias Carumba.CarumbaForm

  def mount(%{"id" => id}, _session, socket) do
    form = CarumbaForm.get_form!(id, load: [:questions, :answers])
    answer = form.answers |> Enum.at(0)

    {:ok, assign(socket, form: form, answer: answer)}
  end

  def handle_event("save_answer", %{"test" => value}, socket) do
    Carumba.CarumbaForm.save_answer(
      value,
      socket.assigns.form.id,
      socket.assigns.form.questions |> Enum.at(0) |> Map.get(:id)
    )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex">
      <div class="w-1/4"><%= @form.slug %></div>
      <div class="w-3/4">
        <.live_component
          :for={question <- @form.questions}
          module={CarumbaWeb.FormLive.Question}
          id={question.id}
          question={question}
          form={@form}
          answer={Enum.find(@form.answers, fn answer -> answer.question_id == question.id end)}
        />
      </div>
    </div>
    """
  end
end
