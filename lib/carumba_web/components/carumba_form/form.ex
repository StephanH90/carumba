defmodule CarumbaWeb.CarumaForm.Form do
  use CarumbaWeb, :live_component

  # @impl true
  # def mount(socket) do
  #   {:ok, socket}
  # end

  # @impl true
  # def update(assigns, socket) do
  #   # form = ash_form(assigns.document, assigns.question, assigns.answer)

  #   # {:ok, assign(socket, form: form, document: document, question: question, answer: answer)}
  # end

  def render(assigns) do
    ~H"""
    <div>
      <div :for={field <- @fieldset.fields}>
        <.live_component
          id={"input-#{field.question.slug}"}
          module={CarumbaWeb.CarumbaForm.Input}
          field={field}
          fieldset={@fieldset}
        />
      </div>
    </div>
    """
  end
end
