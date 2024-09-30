defmodule CarumbaWeb.CarumbaForm.InputV4 do
  use CarumbaWeb, :live_component

  alias Carumba.CarumbaForm.Answer
  alias Carumba.CarumbaForm.Document
  alias Carumba.CarumbaForm.Question

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{document: document, question: question} = assigns, socket) do
    {:ok, answer} = Carumba.CarumbaForm.get_answer(document, question)

    {:ok, assign(socket, answer: answer, form: prepare_form(document, question, answer), question: question)}
  end

  @impl true
  # def render(assigns) do
  def render(assigns) do
    ~H"""
    <div class="mb-8">
      <.form for={@form} phx-change="validate" phx-target={@myself}>
        <label>
          <%= @question.slug %>
          <%= if not @question.is_required? do %>
            <span class="text-gray-400 font-light ml-2">(optional)</span>
          <% end %>
        </label>

        <.input type="text" field={@form[:value]} id={["field-", @question.id]} onkeydown="return event.key != 'Enter';" />

        <div :for={error <- translate_errors(@form.errors, :value)} class="text-red-500 mt-2">
          <%= error %>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"form" => %{"value" => value}}, %{assigns: %{form: form}} = socket) do
    {
      :noreply,
      socket
      |> assign(form: AshPhoenix.Form.validate(form, %{value: value}))
    }

    # case AshPhoenix.Form.validate(form, %{value: value}) do
    #   {:ok, %Answer{} = answer} ->
    #     IO.inspect(answer, pretty: true)
    #     {:noreply, socket}

    #   {:error, form} ->
    #     IO.inspect(form, pretty: true)
    #     {:noreply, assign(socket, form: form)}
    # end
  end

  defp prepare_form(%Document{} = document, %Question{} = question) do
    AshPhoenix.Form.for_create(Answer, :create,
      prepare_source: fn changeset ->
        changeset
        |> Ash.Changeset.set_arguments(question: question.id, document: document.id)
        |> Ash.Changeset.put_context(:document, document)
        |> Ash.Changeset.put_context(:question, question)
      end
    )
    |> to_form()
  end

  defp prepare_form(%Document{} = document, %Question{} = question, %Answer{} = answer) do
    AshPhoenix.Form.for_update(answer, :update,
      params: %{value: answer.value},
      prepare_source: fn changeset ->
        changeset
        |> Ash.Changeset.put_context(:document, document)
        |> Ash.Changeset.put_context(:question, question)
      end
    )
    |> to_form()
  end

  defp prepare_form(%Document{} = document, %Question{} = question, nil) do
    prepare_form(document, question)
  end
end
