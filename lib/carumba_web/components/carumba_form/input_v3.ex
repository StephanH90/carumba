defmodule CarumbaWeb.CarumbaForm.InputLiveV3 do
  use CarumbaWeb, :html

  import CarumbaWeb.CoreComponents, only: [input: 1, translate_errors: 2]

  # alias Carumba.CarumbaForm.{Document, Question, Answer}

  def field(assigns) do
    ~H"""
    <div class="mb-8">
      <%!-- <pre>
        <%= inspect(@field.is_hidden?, pretty: true) %>
      </pre> --%>
      <.form :if={not @field.is_hidden?} for={@form} phx-value-question_id={@question.id}>
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
          id={["field-", @question.id]}
          phx-change={not @form.source.valid? and @form.source.submitted_once? && "save_answer"}
          phx-value-question_id={@question.id}
          phx-blur="save_answer"
          phx-focus="focus_input"
          class={[
            "block w-full p-2 border text-slate-800 font-extralight rounded-none",
            not @form.source.valid? and @form.source.submitted_once? && "text-red-500 border-red-500",
            @field.in_use? && "bg-gray-100"
          ]}
          onkeydown="return event.key != 'Enter';"
          disabled={@field.in_use? && true}
        />

        <div :for={error <- translate_errors(@form.errors, :value)} class="text-red-500 mt-2">
          <%= error %>
        </div>
      </.form>
    </div>
    """
  end
end
