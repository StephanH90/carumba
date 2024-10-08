defmodule CarumbaWeb.CarumbaForm.Input do
  use CarumbaWeb, :live_component

  alias Carumba.CarumbaForm

  @impl true
  def update(assigns, socket) do
    %{fieldset: fieldset, field: field} = assigns

    socket =
      socket
      |> assign(fieldset: fieldset)
      |> assign(field: field)
      |> assign_form(field, fieldset)

    {:ok, socket}
  end

  @impl true
  def handle_event("save_answer", params, socket) do
    %{assigns: %{field: field, fieldset: fieldset, form: form}} = socket
    value = params["form"]["value"] || params["value"]

    if not is_nil(field.answer) and (is_nil(value) or value == "") do
      Ash.destroy!(field.answer)

      {:noreply, socket}
    else
      case AshPhoenix.Form.submit(form, params: %{value: value}) do
        {:ok, answer} ->
          send(self(), {:updated_answer, answer})

          socket =
            socket
            |> assign_form(field, fieldset)
            |> assign(field: %{field | answer: answer})

          {:noreply, socket}

        {:error, form} ->
          {:noreply, assign(socket, form: form)}
      end
    end
  end

  @impl true
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
          <%= @field.question.slug %>
          <%= if not @field.question.is_required? do %>
            <span class="text-gray-400 font-light ml-2">(optional)</span>
          <% end %>
        </label>
        <.input
          type="text"
          id={"#{@field.question.slug}-input"}
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

  defp assign_form(socket, field, fieldset) when is_nil(field.answer) do
    form =
      AshPhoenix.Form.for_create(CarumbaForm.Answer, :create,
        prepare_source: fn changeset ->
          changeset
          |> Ash.Changeset.set_arguments(question: field.question.slug, document: fieldset.document.id)
          |> Ash.Changeset.put_context(:document, fieldset.document)
          |> Ash.Changeset.put_context(:question, field.question)
        end
      )
      |> to_form()

    assign(socket, form: form)
  end

  defp assign_form(socket, field, fieldset) do
    form =
      AshPhoenix.Form.for_update(field.answer, :update,
        params: %{value: field.answer.value},
        prepare_source: fn changeset ->
          changeset
          |> Ash.Changeset.put_context(:document, fieldset.document)
          |> Ash.Changeset.put_context(:question, field.question)
        end
      )
      |> to_form()

    assign(socket, form: form)
  end
end
