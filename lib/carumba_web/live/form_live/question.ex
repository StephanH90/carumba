defmodule CarumbaWeb.FormLive.Question do
  use CarumbaWeb, :live_component
  alias Carumba.CarumbaForm.Answer

  def update(assigns, socket) do
    answer_form = prepare_form(assigns.answer, assigns)

    {
      :ok,
      assign(socket,
        form: assigns.form,
        question: assigns.question,
        answer_form: answer_form
      )
    }
  end

  defp prepare_form(%Answer{} = answer, _assigns) do
    AshPhoenix.Form.for_update(answer, :update)
    |> AshPhoenix.Form.validate(%{value: answer.value})
    |> to_form()
  end

  defp prepare_form(nil, assigns) do
    AshPhoenix.Form.for_create(Answer, :create)
    |> AshPhoenix.Form.validate(%{form: assigns.form.id, question: assigns.question.id})
    |> to_form()
  end

  def handle_event("save_answer", %{"form" => %{"value" => value}}, socket) do
    params = %{
      form: socket.assigns.form.id,
      question: socket.assigns.question.id,
      value: value
    }

    AshPhoenix.Form.submit(socket.assigns.answer_form, params: params)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form :let={f} for={@answer_form} phx-change="save_answer" phx-target={@myself}>
        <div class="flex items-center">
          <.input type="text" field={f[:value]} phx-debounce="blur" />
          <.spinner />
        </div>
      </.form>
    </div>
    """
  end

  def spinner(assigns) do
    ~H"""
    <div class="ml-2 loading-spinner transition-opacity ease-out duration-300">
      <svg
        class="animate-spin h-5 w-5 text-green-500"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
      >
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
        </circle>
        <path
          class="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        >
        </path>
      </svg>
    </div>
    """
  end
end
