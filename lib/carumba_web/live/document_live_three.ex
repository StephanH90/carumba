defmodule CarumbaWeb.DocumentLiveV3 do
  use CarumbaWeb, :live_view

  alias Carumba.CarumbaForm.{Document, Question, Answer}

  import CarumbaWeb.CarumbaForm.InputLiveV3, only: [field: 1]

  def mount(_params, _session, socket) do
    document =
      Ash.read_one!(Document, load: [answers: [:question], form: [:questions]])

    CarumbaWeb.Endpoint.subscribe("document-#{document.id}")

    {
      :ok,
      socket
      |> assign(document: document)
      |> assign(fields: prepare_fields(document))
      |> assign(my_id: :rand.uniform(10000))
    }
  end

  def render(assigns) do
    ~H"""
    <div>
      <.field
        :for={field <- @fields}
        id={["field-", field.question.id]}
        form={field.form}
        question={field.question}
        field={field}
      />
    </div>
    """
  end

  def handle_event("save_answer", params, %{assigns: %{document: document}} = socket) do
    value = params["form"]["value"] || params["value"]
    question_id = params["form"]["question_id"] || params["question_id"]

    with %{question: question} <- get_field_for_question(socket, question_id),
         {:ok, answer} <- Carumba.CarumbaForm.get_answer(document, question) do
      {
        :noreply,
        socket
        |> handle_save_event(question, answer, %{value: value})
      }
    end
  end

  def handle_event("focus_input", %{"question_id" => question_id}, socket) do
    CarumbaWeb.Endpoint.broadcast_from!(
      self(),
      "document-#{socket.assigns.document.id}",
      "input_focused",
      {question_id, socket.assigns.my_id, true}
    )

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
  def handle_save_event(socket, %Question{is_required?: false} = question, %Answer{} = answer, %{value: value})
      when value == "" do
    Ash.destroy!(answer)

    socket
    |> update_field_form(question)
  end

  def handle_save_event(socket, %Question{is_required?: false}, answer, %{value: value}, socket)
      when is_nil(answer) and value == "" do
    # There is no answer to destroy and the question is not required so we can just do nothing
    socket
  end

  def handle_save_event(%{assigns: %{document: document}} = socket, %Question{} = question, _answer, params) do
    form = get_field_for_question(socket, question.id).form

    case AshPhoenix.Form.submit(form, params: params) do
      {:ok, %Answer{} = answer} ->
        CarumbaWeb.Endpoint.broadcast_from!(self(), "document-#{document.id}", "updated_answer", answer)

        CarumbaWeb.Endpoint.broadcast_from!(
          self(),
          "document-#{document.id}",
          "input_focused",
          {question.id, socket.assigns.my_id, false}
        )

        socket
        |> update_field_form(question, answer)
        |> update_or_append_answer(answer)

      {:error, form} ->
        socket
        |> update_field_form(question, form)
    end
  end

  def update_or_append_answer(%{assigns: %{document: %{answers: answers} = document}} = socket, %Answer{} = answer) do
    new_answers =
      answers
      |> Enum.reject(fn a -> a.question_id == answer.question_id end)
      |> Enum.concat([answer])

    socket
    |> assign(document: %{document | answers: new_answers})
  end

  def update_field_form(
        %{assigns: %{fields: fields, document: document}} = socket,
        %Question{id: question_id} = question
      ) do
    fields =
      Enum.map(fields, fn
        %{question: %{id: ^question_id}} = field -> %{field | form: prepare_form(document, question)}
        field -> field
      end)

    assign(socket, fields: fields)
  end

  def update_field_form(
        %{assigns: %{fields: fields}} = socket,
        %{id: question_id} = %Question{},
        form = %Phoenix.HTML.Form{}
      ) do
    fields =
      Enum.map(fields, fn
        %{question: %{id: ^question_id}} = field -> %{field | form: form}
        field -> field
      end)

    assign(socket, fields: fields)
  end

  def update_field_form(
        %{assigns: %{fields: fields, document: document}} = socket,
        %Question{id: question_id} = question,
        answer = %Answer{}
      ) do
    fields =
      Enum.map(fields, fn
        %{question: %{id: ^question_id}} = field -> %{field | form: prepare_form(document, question, answer)}
        field -> field
      end)

    assign(socket, fields: fields)
  end

  def prepare_fields(%Document{form: %{questions: questions}} = document) do
    Enum.map(questions, fn question ->
      {:ok, answer} = Carumba.CarumbaForm.get_answer(document, question)

      %{
        question: question,
        form: prepare_form(document, question, answer),
        in_use?: false,
        # is_hidden?: Carumba.QuestionParser.parse_and_evaluate(question.is_hidden, document)
        is_hidden?: false
      }
    end)
  end

  def set_in_use(socket, question_id, new_value) do
    fields =
      Enum.map(socket.assigns.fields, fn
        %{question_id: ^question_id} = field -> %{field | in_use?: new_value}
        field -> field
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
    prepare_form(document, question)
  end

  def prepare_form(%Document{} = document, %Question{} = question) do
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
