defmodule CarumbaWeb.CarumaForm.Form do
  use CarumbaWeb, :live_component

  @impl true
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
