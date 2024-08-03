defmodule CarumbaWeb.CarumbaForm.InputLiveV3 do
  use CarumbaWeb, :html

  import CarumbaWeb.CoreComponents, only: [input: 1, translate_errors: 2]

  # alias Carumba.CarumbaForm.{Document, Question, Answer}

  def field(assigns) do
    ~H"""
    <div class="mb-8">
      <%!-- <pre>
        <%= inspect(@form, pretty: true) %>
      </pre> --%>
      <.form for={@form} phx-value-question_id={@question.id}>
        <label class={[
          "block font-medium mb-2",
          !@form.source.valid? && length(@form.errors) > 0 && "text-red-600"
        ]}>
          <%= @question.slug %>
          <%= if not @question.is_required? do %>
            <span class="text-gray-400 font-light ml-2">(optional)</span>
          <% end %>
        </label>
        <.input
          type="text"
          field={@form[:value]}
          phx-change={not @form.source.valid? && "save_answer"}
          phx-value-question_id={@question.id}
          phx-blur="save_answer"
        />

        <div :for={error <- translate_errors(@form.errors, :value)} class="text-red-500 mt-2">
          <%= error %>
        </div>
      </.form>
    </div>
    """
  end
end
