defmodule CarumbaWeb.DocumentLiveV3 do
  use CarumbaWeb, :live_view

  alias Carumba.CarumbaForm.{Document, Question, Answer}

  import CarumbaWeb.CarumbaForm.InputLiveV3, only: [field: 1]

  def mount(%{"id" => id}, _session, socket) do
    document =
      Ash.get!(Carumba.CarumbaForm.Document, %{id: id}, load: [:answers, form: [:questions]])

    fields = prepare_fields(document)

    {:ok, assign(socket, document: document, fields: fields)}
  end

  def get_answer_for_question(%Document{answers: answers}, %Question{id: question_id}) do
    Enum.find(answers, fn answer -> answer.question_id == question_id end)
  end

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

  def prepare_form(
        %Document{id: document_id} = document,
        %Question{id: question_id} = question,
        nil
      ) do
    AshPhoenix.Form.for_create(Answer, :create,
      prepare_source: fn changeset ->
        changeset
        |> Ash.Changeset.set_arguments(question: question_id, document: document_id)
        |> Ash.Changeset.put_context(:document, document)
        |> Ash.Changeset.put_context(:question, question)
      end
    )
    |> to_form()
  end

  def render(assigns) do
    ~H"""
    <div>
      <.field
        :for={field <- @fields}
        id={["field-", field.question.id]}
        form={field.form}
        question={field.question}
      />
    </div>
    """
  end

  def handle_info({:updated_answer, _new_answer}, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "save_answer",
        params,
        socket
      ) do
    value = params["form"]["value"] || params["value"]
    question_id = params["form"]["question_id"] || params["question_id"]

    %{question: question} = get_field_for_question(socket, question_id)

    answer = get_answer(socket.assigns.document, question)

    handle_save_event(question, answer, %{value: value}, socket)
  end

  @doc """
  When trying to save an empty value for a non-required question, we destroy the answer instead
  """
  def handle_save_event(
        %Question{is_required?: false} = question,
        %Answer{} = answer,
        %{value: value},
        socket
      )
      when value == "" do
    Ash.destroy!(answer)

    fields = update_field_form(socket, question, nil, nil)

    {:noreply, assign(socket, fields: fields)}
  end

  def handle_save_event(%Question{} = question, _answer, params, socket) do
    form = get_field_for_question(socket, question.id).form

    case AshPhoenix.Form.submit(form, params: params) do
      {:ok, %Answer{} = answer} ->
        fields = update_field_form(socket, question, answer, nil)
        {:noreply, assign(socket, fields: fields)}

      {:error, form} ->
        fields = update_field_form(socket, question, _answer, form)
        {:noreply, assign(socket, fields: fields)}
    end
  end

  @doc """
  Updates the form for a given question with a new pheonxi form
  """
  def update_field_form(
        %{assigns: %{fields: fields}} = socket,
        question,
        _answer,
        %Phoenix.HTML.Form{} = form
      ) do
    Enum.map(fields, fn field ->
      if field.question.id == question.id do
        %{field | form: form}
      else
        field
      end
    end)
  end

  def update_field_form(%{assigns: %{fields: fields}} = socket, question, answer, _form) do
    Enum.map(fields, fn field ->
      if field.question.id == question.id do
        %{field | form: prepare_form(socket.assigns.document, question, answer)}
      else
        field
      end
    end)
  end

  def prepare_fields(%Document{form: %{questions: questions}} = document) do
    Enum.map(questions, fn question ->
      answer = get_answer_for_question(document, question)

      %{
        question: question,
        form: prepare_form(document, question, answer)
      }
    end)
  end

  def get_field_for_question(%{assigns: %{fields: fields}}, question_id) do
    Enum.find(fields, fn field -> field.question.id == question_id end)
  end

  def get_answer(%Document{} = document, %Question{} = question) do
    Enum.find(document.answers, fn answer -> answer.question_id == question.id end)
  end
end
