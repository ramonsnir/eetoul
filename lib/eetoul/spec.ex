defmodule Eetoul.Spec.ParseError do
  defexception message: "Invalid spec."
end

defmodule Eetoul.Spec do
  alias Eetoul.Spec.ParseError

  @type eetoul_spec :: [(
    {:checkout, String.t} |
    {:take, String.t, (:default | {:squash, String.t} | :merge)}
  )]

  def parse spec do
    spec
    |> String.split(["\n", "\r"], trim: true)
    |> Enum.map(&(String.split(&1, "#")))
    |> Enum.map(&(Enum.at(&1, 0)))
    |> Enum.map(&parse_line/1)
  end

  defp parse_line line do
    [command, reference, message] =
      case String.split(line, " ", parts: 3, trim: true) do
        [command] -> [command, nil, nil]
        [command, reference] -> [command, reference, nil]
        all -> all
      end
    validate_argument = fn arg_name, arg_value, required ->
      if arg_value == nil && required do
        raise ParseError, message: "`#{command}` expects a #{arg_name} argument."
      end
      if arg_value != nil && !required do
        raise ParseError, message: "`#{command}` does not expect a #{arg_name} argument."
      end
    end
    case command do
      "checkout" ->
        validate_argument.(:reference, reference, true)
        validate_argument.(:message, message, false)
        {:checkout, reference}
      "take" ->
        validate_argument.(:reference, reference, true)
        validate_argument.(:message, message, false)
        {:take, reference, :default}
      "take-squash" ->
        validate_argument.(:reference, reference, true)
        validate_argument.(:message, message, true)
        {:take, reference, {:squash, message}}
      "take-merge" ->
        validate_argument.(:reference, reference, true)
        validate_argument.(:message, message, false)
        {:take, reference, :merge}
    end
  end
end
