defmodule CarumbaWeb.DocumentLive do
  use CarumbaWeb, :live_view

  import CarumbaWeb.CarumbaForm.Input, only: [carumba_field: 1]

  # TODO: RENAME VALIDIAIONS TO FIELDS or fieldsets?
  def mount(_params, _session, socket) do
    # document =
    #   Ash.get!(Carumba.CarumbaForm.Document, %{id: id},
    #     load: [:answers, :fieldsets, form: [:questions]]
    #   )
    # ! Just for testing we always load the first document that was seeded
    document = Ash.read_one!(Carumba.CarumbaForm.Document, load: [:answers, :fieldsets, form: [:questions]])

    {:ok, assign(socket, document: document, fieldsets: document.fieldsets)}
  end

  def handle_info({:updated_answer, _answer}, socket) do
    # Todo: dont refetch all answers?
    document = Ash.load!(socket.assigns.document, [:answers, :fieldsets])

    {:noreply, assign(socket, document: document)}
  end

  def handle_event("update_answer", %{"question_id" => question_id, "value" => value}, socket) do
    fieldsets =
      if Enum.find(socket.assigns.fieldsets, fn validation ->
           validation.question.id == question_id and not is_nil(validation.answer)
         end) do
        # an answer exists and we need to update it
        Enum.map(socket.assigns.fieldsets, fn validation ->
          if not validation.question.is_required? and value == "" do
            # we are trying to delete an answer
            Ash.destroy!(validation.answer)
            Map.merge(validation, %{errors: [], temp_value: nil, answer: nil})
          else
            if validation.question.id == question_id do
              case Ash.update(validation.answer, %{value: value}, atomic_upgrade?: false) do
                {:ok, answer} ->
                  Map.merge(validation, %{answer: answer, temp_value: nil, errors: []})

                {:error, changeset} ->
                  Map.merge(validation, %{errors: changeset.errors, temp_value: value})
              end
            else
              validation
            end
          end
        end)
      else
        # there is no answer yet and we need to create one
        Enum.map(socket.assigns.fieldsets, fn validation ->
          if validation.question.id == question_id do
            case Ash.create(Carumba.CarumbaForm.Answer, %{
                   question: question_id,
                   document: socket.assigns.document.id,
                   value: value
                 }) do
              {:ok, answer} ->
                Map.merge(validation, %{answer: answer, temp_value: nil, errors: []})

              {:error, changeset} ->
                Map.merge(validation, %{errors: changeset.errors, temp_value: value})
            end
          else
            validation
          end
        end)
      end

    {:noreply, assign(socket, fieldsets: fieldsets)}
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-4 gap-8">
      <div class="col-span-1">one</div>
      <div class="col-span-3">
        <.carumba_field :for={field <- @fieldsets} field={field} errors={field.errors} />
      </div>
    </div>
    """
  end
end
