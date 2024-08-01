defmodule CarumbaWeb.DocumentLive do
  use CarumbaWeb, :live_view

  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     assign(socket,
       document:
         Ash.get!(Carumba.CarumbaForm.Document, %{id: id},
           load: [:answers, :validations, form: :questions]
         )
     )}
  end

  def handle_info({:updated_answer, _answer}, socket) do
    # Todo: dont refetch all answers?
    document = Ash.load!(socket.assigns.document, [:answers, :validations])

    {:noreply, assign(socket, document: document)}
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-4 gap-8">
      <div class="col-span-1">one</div>
      <div class="col-span-3">
        <%!-- <.question :for={question <- @document.form.questions} question={question} /> --%>
        <.live_component
          :for={question <- @document.form.questions}
          id={question.slug}
          module={CarumbaWeb.FormLive.Question}
          document={@document}
          question={question}
          validations={@document.validations}
        />
      </div>
    </div>
    """
  end

  # def question(assigns) do
  #   ~H"""
  #   <div class="mb-8">
  #     <label class="block text-gray-700 text-sm font-bold mb-2" for="form-stacked-text">
  #       <%= @question.slug %>
  #     </label>
  #     <div class="relative">
  #       <input
  #         class="border border-gray-200 w-full p-3 text-gray-700 focus:border-blue-200 transition-colors ease-in-out duration-300"
  #         type="text"
  #         placeholder="Some text..."
  #         value={}"
  #       />
  #     </div>
  #   </div>
  #   """
  # end
end
