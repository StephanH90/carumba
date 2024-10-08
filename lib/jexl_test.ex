defmodule JexlParser do
  import NimbleParsec

  # Define parsers for different elements of JEXL
  number =
    optional(ascii_char([?-]))
    |> ascii_string([?0..?9], min: 1)
    |> optional(ascii_char([?.]) |> ascii_string([?0..?9], min: 1))
    |> reduce(:to_number)

  identifier =
    ascii_string([?a..?z, ?A..?Z, ?_], min: 1)
    |> ascii_string([?a..?z, ?A..?Z, ?0..?9, ?_], min: 0)
    |> reduce(:to_identifier)

  whitespace = ascii_char([?\s, ?\t, ?\n, ?\r]) |> times(min: 0)

  # Operators with precedence
  mult_div =
    choice([
      string("*"),
      string("/")
    ])

  add_sub =
    choice([
      string("+"),
      string("-")
    ])

  comparison =
    choice([
      string("=="),
      string("!="),
      string(">="),
      string("<="),
      string(">"),
      string("<")
    ])

  # Term can be a number, identifier, or parenthesized expression
  term =
    choice([
      parsec(:parens),
      number,
      identifier
    ])
    |> unwrap_and_tag(:term)

  # Factor handles multiplication and division
  factor =
    term
    |> repeat(
      whitespace
      |> concat(mult_div)
      |> concat(whitespace)
      |> concat(term)
    )
    |> tag(:factor)

  # Arithmetic handles addition and subtraction
  arithmetic =
    factor
    |> repeat(
      whitespace
      |> concat(add_sub)
      |> concat(whitespace)
      |> concat(factor)
    )
    |> tag(:arithmetic)

  # Comparison is the highest level operation
  expression =
    arithmetic
    |> optional(
      whitespace
      |> concat(comparison)
      |> concat(whitespace)
      |> concat(arithmetic)
    )
    |> tag(:expression)

  # Parenthesized expression
  defcombinatorp(
    :parens,
    ignore(ascii_char([?(]))
    |> concat(expression)
    |> ignore(ascii_char([?)]))
    |> label("parenthesized expression")
  )

  defparsec(:parse, expression)

  # Evaluation functions
  def evaluate(input) do
    case parse(input) do
      {:ok, [result], "", _, _, _} ->
        {:ok, eval_ast(result)}

      {:error, reason, _, _, _, _} ->
        {:error, "Failed to parse: #{reason}"}
    end
  end

  defp eval_ast({:expression, [left, op, right]}) when is_binary(op) do
    apply_operator(eval_ast(left), op, eval_ast(right))
  end

  defp eval_ast({:expression, [expr]}), do: eval_ast(expr)

  defp eval_ast({:arithmetic, [head | tail]}) do
    Enum.reduce(tail, eval_ast(head), fn
      {op, factor}, acc -> apply_operator(acc, op, eval_ast(factor))
    end)
  end

  defp eval_ast({:factor, [head | tail]}) do
    Enum.reduce(tail, eval_ast(head), fn
      {op, term}, acc -> apply_operator(acc, op, eval_ast(term))
    end)
  end

  defp eval_ast({:term, value}), do: eval_ast(value)
  defp eval_ast(num) when is_number(num), do: num
  # In a real scenario, you'd look up the value of the identifier
  defp eval_ast(id) when is_atom(id), do: id

  defp apply_operator(left, "==", right), do: left == right
  defp apply_operator(left, "!=", right), do: left != right
  defp apply_operator(left, ">=", right), do: left >= right
  defp apply_operator(left, "<=", right), do: left <= right
  defp apply_operator(left, ">", right), do: left > right
  defp apply_operator(left, "<", right), do: left < right
  defp apply_operator(left, "+", right), do: left + right
  defp apply_operator(left, "-", right), do: left - right
  defp apply_operator(left, "*", right), do: left * right
  defp apply_operator(left, "/", right), do: left / right

  defp to_number(chars) do
    number = chars |> Enum.join()

    case String.contains?(number, ".") do
      true -> String.to_float(number)
      false -> String.to_integer(number)
    end
  end

  defp to_identifier(chars), do: chars |> Enum.join() |> String.to_atom()
end
