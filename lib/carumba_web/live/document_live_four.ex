defmodule CarumbaWeb.DocumentLiveV4 do
  use CarumbaWeb, :live_view

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:document, Ash.read_one!(Carumba.CarumbaForm.Document, load: [form: :questions]))
    }
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Document Live V4</h1>
      <.live_component
        :for={question <- @document.form.questions}
        id={question.id}
        document={@document}
        question={question}
        module={CarumbaWeb.CarumbaForm.InputV4}
      />
    </div>
    """
  end
end
