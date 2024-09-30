defmodule Carumba.QuestionParser do
  alias Carumba.CarumbaForm.Answer
  alias Carumba.CarumbaForm.Document

  def parse_and_evaluate(input, %Document{} = document) do
    case parse_string(input) do
      true ->
        true

      false ->
        false

      {slug, logic} ->
        case fetch_value_of_answer_for_question(document, slug) do
          {:ok, value} ->
            case evaluate_logic(logic, value) do
              {:ok, result} -> result
              error -> error
            end

          error ->
            error
        end
    end
  end

  def parse_and_evaluate(input, fetch_value_fn) do
    with {slug, logic} <- parse_string(input),
         {:ok, value} <- fetch_value_fn.(slug),
         {:ok, result} <- evaluate_logic(logic, value) do
      {:ok, slug, result}
    else
      error -> error
    end
  end

  def fetch_value_of_answer_for_question(%Document{} = document, slug) do
    case Ash.calculate(document, :find_answer_for_question, args: %{slug: slug}) do
      {:ok, %Answer{value: value}} -> {:ok, value}
      error -> error
    end
  end

  def parse_string(input) when input == "true", do: true
  def parse_string(input) when input == "false", do: false

  def parse_string(input) do
    case String.split(input, "|", parts: 2) do
      [slug_part, logic_part] ->
        slug = slug_part |> String.trim("\"")
        logic = String.trim(logic_part)
        {slug, logic}

      _ ->
        {:error, "Invalid format"}
    end
  end

  def evaluate_logic(logic, value) do
    case Regex.run(~r/^(\w+)\s*([><=]+)\s*(\d+)$/, logic) do
      [_, "answer", operator, threshold] ->
        threshold = String.to_integer(threshold)

        result =
          case operator do
            ">" -> value > threshold
            "<" -> value < threshold
            ">=" -> value >= threshold
            "<=" -> value <= threshold
            "==" -> value == threshold
            _ -> {:error, "Invalid operator"}
          end

        {:ok, result}

      _ ->
        {:error, "Invalid logic format"}
    end
  end
end
