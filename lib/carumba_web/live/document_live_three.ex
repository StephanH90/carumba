defmodule CarumbaWeb.DocumentLiveV3 do
  use CarumbaWeb, :live_view

  alias Carumba.CarumbaForm.{Document, Question, Answer}

  import CarumbaWeb.CarumbaForm.InputLiveV3, only: [field: 1]

  def mount(%{"id" => id}, _session, socket) do
    # ! Just for testing we always load the first document that was seeded
    # document =
    #   Ash.get!(Carumba.CarumbaForm.Document, %{id: id}, load: [:answers, form: [:questions]])
    document =
      Ash.read_one!(Carumba.CarumbaForm.Document, load: [answers: :question, form: [:questions]])

    CarumbaWeb.Endpoint.subscribe("document-#{document.id}")

    fields = prepare_fields(document)

    my_id = :rand.uniform(10000)

    {:ok, assign(socket, document: document, fields: fields, my_id: my_id)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.field :for={field <- @fields} id={["field-", field.question.id]} form={field.form} question={field.question} field={field} />
    </div>
    """
  end

  def handle_event("save_answer", params, %{assigns: %{document: document}} = socket) do
    value = params["form"]["value"] || params["value"]
    question_id = params["form"]["question_id"] || params["question_id"]

    %{question: question} = get_field_for_question(socket, question_id)

    answer = Ash.calculate!(document, :find_answer_for_question, args: %{slug: question.slug})

    handle_save_event(question, answer, %{value: value}, socket)
  end

  def handle_event("focus_input", %{"question_id" => question_id}, socket) do
    CarumbaWeb.Endpoint.broadcast_from!(self(), "document-#{socket.assigns.document.id}", "input_focused", {question_id, socket.assigns.my_id, true})

    {:noreply, socket}
  end

  def handle_info(%{event: "input_focused", payload: {question_id, user_id, new_state}}, socket) do
    {:noreply, set_in_use(socket, question_id, new_state)}
  end

  def handle_info(%{event: "updated_answer", payload: updated_document}, socket) do
    fields = prepare_fields(updated_document)
    {:noreply, assign(socket, document: updated_document, fields: fields)}
  end

  @doc """
  When trying to save an empty value for a non-required question, we destroy the answer instead
  """
  def handle_save_event(%Question{is_required?: false} = question, %Answer{} = answer, %{value: value}, socket) when value == "" do
    Ash.destroy!(answer)

    fields = update_field_form(socket, question, nil, nil)

    {:noreply, assign(socket, fields: fields)}
  end

  def handle_save_event(%Question{is_required?: false}, answer, %{value: value}, socket) when is_nil(answer) and value == "" do
    # There is no answer to destroy and the question is not required so we can just do nothing
    {:noreply, socket}
  end

  def handle_save_event(%Question{} = question, answer, params, socket) do
    form = get_field_for_question(socket, question.id).form

    case AshPhoenix.Form.submit(form, params: params) do
      {:ok, %Answer{} = answer} ->
        fields = update_field_form(socket, question, answer, nil)
        document = update_or_append_answer(socket.assigns.document, answer)
        fields = prepare_fields(document)

        CarumbaWeb.Endpoint.broadcast_from!(self(), "document-#{document.id}", "updated_answer", document)
        CarumbaWeb.Endpoint.broadcast_from!(self(), "document-#{document.id}", "input_focused", {question.id, socket.assigns.my_id, false})

        {:noreply, assign(socket, fields: fields, document: document)}

      {:error, form} ->
        fields = update_field_form(socket, question, answer, form)
        {:noreply, assign(socket, fields: fields)}
    end
  end

  def update_or_append_answer(%Document{answers: answers} = document, %Answer{} = answer) do
    new_answers =
      Enum.filter(answers, fn a -> a.question_id != answer.question_id end) ++ [answer]

    %{document | answers: new_answers}
  end

  def update_field_form(%{assigns: %{fields: fields, document: document}}, question, answer, form) do
    Enum.map(fields, fn field ->
      if field.question.id == question.id do
        %{field | form: form || prepare_form(document, question, answer)}
      else
        field
      end
    end)
  end

  def prepare_fields(%Document{form: %{questions: questions}} = document) do
    Enum.map(questions, fn question ->
      answer = Ash.calculate!(document, :find_answer_for_question, args: %{slug: question.slug})

      %{
        question: question,
        form: prepare_form(document, question, answer),
        in_use?: false,
        is_hidden?: Carumba.QuestionParser.parse_and_evaluate(question.is_hidden, document)
      }
    end)
  end

  def set_in_use(socket, question_id, new_value) do
    fields =
      Enum.map(socket.assigns.fields, fn field ->
        if field.question.id == question_id do
          %{field | in_use?: new_value}
        else
          field
        end
      end)

    assign(socket, fields: fields)
  end

  @doc """
  Prepare a form to create or update an answer
  """
  def prepare_form(%Document{} = document, %Question{} = question, %Answer{} = answer) do
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

  def prepare_form(%Document{} = document, %Question{} = question, nil) do
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

  def get_field_for_question(%{assigns: %{fields: fields}}, question_id) do
    Enum.find(fields, fn field -> field.question.id == question_id end)
  end
end
