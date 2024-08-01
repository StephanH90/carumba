defmodule CarumbaWeb.FormLive.Question do
  use CarumbaWeb, :live_component
  alias Carumba.CarumbaForm.Answer

  def update(assigns, socket) do
    answer =
      Enum.find(assigns.document.answers, fn answer ->
        answer.question_id == assigns.question.id
      end)

    answer_form = prepare_form(answer, %{document: assigns.document, question: assigns.question})

    {
      :ok,
      assign(socket,
        question: assigns.question,
        answer_form: answer_form,
        validations: assigns.validations,
        has_been_blurred?: false,
        answer: answer,
        document: assigns.document
      )
    }
  end

  defp prepare_form(%Answer{} = answer, _assigns) do
    AshPhoenix.Form.for_update(answer, :update)
    |> AshPhoenix.Form.validate(%{value: answer.value})
    |> to_form()
  end

  defp prepare_form(nil, %{document: document, question: question}) do
    AshPhoenix.Form.for_create(Answer, :create)
    |> AshPhoenix.Form.validate(%{document: document.id, question: question.id})
    |> to_form()
  end

  def handle_event("save_answer", %{"form" => %{"value" => value}}, socket) do
    params = Map.put(socket.assigns.answer_form.params, :value, value)

    if params.value == "" do
      Ash.destroy!(socket.assigns.answer)

      answer_form =
        prepare_form(socket.assigns.answer, %{
          document: socket.assigns.document,
          question: socket.assigns.question
        })

      {:noreply, assign(socket, answer_form: answer_form)}
    else
      case AshPhoenix.Form.submit(socket.assigns.answer_form, params: params) do
        {:ok, answer} ->
          send(self(), {:updated_answer, answer})
          {:noreply, socket}

        {:error, form} ->
          {:noreply, assign(socket, answer_form: form)}
      end
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mb-8">
      <.form for={@answer_form} phx-change="save_answer" phx-target={@myself}>
        <label class="block text-gray-700 text-sm font-bold mb-2" for="form-stacked-text">
          <%= @question.slug %>
        </label>
        <div class="relative">
          <.input
            type="text"
            field={@answer_form[:value]}
            class={[
              "border w-full p-3 text-gray-700 focus:border-blue-200 transition-colors ease-in-out duration-300"
            ]}
          />
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
