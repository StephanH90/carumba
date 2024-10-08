defmodule CarumbaWeb.CarumbaForm.InputLive do
  use CarumbaWeb, :live_component

  import CarumbaWeb.CoreComponents, only: [input: 1, translate_errors: 2]

  alias Carumba.CarumbaForm.{Document, Question, Answer}

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{document: document, question: question, answer: answer} = assigns, socket) do
    form = ash_form(assigns.document, assigns.question, assigns.answer)

    {:ok, assign(socket, form: form, document: document, question: question, answer: answer)}
  end

  def handle_event(
        "save_answer",
        params,
        %{assigns: %{document: document, question: question, answer: answer, form: form}} = socket
      ) do
    value = params["form"]["value"] || params["value"]

    if not question.is_required? and (not is_nil(answer) and (is_nil(value) or value == "")) do
      Ash.destroy!(answer)

      {:noreply, assign(socket, form: ash_form(document, question, nil))}
    else
      case AshPhoenix.Form.submit(form, params: %{value: value}) do
        {:ok, %Answer{} = answer} ->
          send(self(), {:updated_answer, answer})

          {:noreply, assign(socket, form: ash_form(document, question, answer), answer: answer)}

        {:error, form} ->
          {:noreply, assign(socket, form: form)}
      end
    end
  end

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="mb-8">
      <%!-- <pre>
        <%= inspect(@form, pretty: true) %>
      </pre> --%>
      <.form for={@form}>
        <label class={[
          "block font-medium mb-2",
          !@form.source.valid? && length(@form.errors) > 0 && "text-red-600"
        ]}>
          <%= @question.slug %>
          <%= if not @question.is_required? do %>
            <span class="text-gray-400 font-light ml-2">(optional)</span>
          <% end %>
        </label>
        <.input
          type="text"
          field={@form[:value]}
          phx-change={not @form.source.valid? && "save_answer"}
          phx-blur="save_answer"
          phx-target={@myself}
        />

        <div :for={error <- translate_errors(@form.errors, :value)} class="text-red-500 mt-2">
          <%= error %>
        </div>
      </.form>
    </div>
    """
  end

  def ash_form(%Document{} = document, %Question{} = question, %Answer{} = answer) do
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

  def ash_form(%Document{id: document_id} = document, %Question{slug: slug} = question, nil) do
    AshPhoenix.Form.for_create(Answer, :create,
      prepare_source: fn changeset ->
        changeset
        |> Ash.Changeset.set_arguments(question: slug, document: document_id)
        |> Ash.Changeset.put_context(:document, document)
        |> Ash.Changeset.put_context(:question, question)
      end
    )
    |> to_form()
  end
end
