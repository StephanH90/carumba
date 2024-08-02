defmodule CarumbaWeb.CarumbaForm.Input do
  use Phoenix.Component

  import CarumbaWeb.CoreComponents, only: [translate_error: 1]

  attr :input, :map, required: true

  def carumba_field(assigns) do
    ~H"""
    <div class="mb-8">
      <label class={[
        "block font-medium mb-2",
        length(@errors) > 0 && "text-red-600"
      ]}>
        <%= @field.question.slug %>
        <%= if not @field.question.is_required? do %>
          <span class="text-gray-400 font-light ml-2">(optional)</span>
        <% end %>
      </label>
      <input
        type="text"
        name={@field.slug}
        phx-blur="update_answer"
        phx-value-question_id={@field.question.id}
        value={
          if @field.temp_value do
            @field.temp_value
          else
            if @field.answer do
              @field.answer.value
            end
          end
        }
        class={[
          "block w-full p-2 border border-gray-300 text-slate-800 font-extralight",
          length(@errors) > 0 && "border-red-500"
        ]}
      />
      <div :for={error <- @errors} class="text-red-500 mt-2">
        <%= translate_error({error.message, error.vars}) %>
      </div>
    </div>
    """
  end
end
