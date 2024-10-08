defmodule CarumbaWeb.DocumentLive do
  use CarumbaWeb, :live_view

  alias Carumba.CarumbaForm
  alias CarumbaWeb.CarumbaForm.FieldsetHelpers

  @impl true
  def mount(params, _session, socket) do
    %{"id" => id} = params

    document =
      CarumbaForm.get_document!(id, load: [:answers, form: [questions: [sub_form: [questions: :sub_form]]]])

    fieldset = FieldsetHelpers.construct_fieldset(document, document.form)

    socket =
      socket
      |> assign(fieldset: fieldset)
      |> assign(document: document)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    %{assigns: %{fieldset: fieldset}} = socket

    current_fieldset =
      case params["form"] do
        nil -> fieldset.fieldsets |> hd()
        form_slug -> fieldset.fieldsets |> Enum.find(&(&1.form.slug == form_slug))
      end

    socket =
      socket
      |> assign(current_fieldset: current_fieldset)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:updated_answer, answer}, socket) do
    %{assigns: %{fieldset: fieldset}} = socket

    fieldset = FieldsetHelpers.update_answer_in_fieldset(fieldset, answer)

    socket =
      socket
      |> assign(fieldset: fieldset)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-4 gap-8">
      <div class="col-span-1">
        <.navigation fieldsets={@fieldset.fieldsets} />
      </div>
      <div class="col-span-3">
        <.live_component id="form" module={CarumbaWeb.CarumaForm.Form} fieldset={@current_fieldset} />
      </div>
    </div>
    """
  end

  defp navigation(assigns) do
    ~H"""
    <ul id="document-navigation" phx-update="stream">
      <li :for={fieldset <- @fieldsets} id={"fieldset-#{fieldset.form.slug}"}>
        <.link patch={"?form=#{fieldset.form.slug}"}><%= fieldset.form.slug %></.link>
      </li>
    </ul>
    """
  end
end
