defmodule Eetoul.Spec.ParseError do
  defexception message: "Invalid spec."
end

defmodule Eetoul.Spec.ValidationError do
  defexception message: "Invalid spec."
end

defmodule Eetoul.Spec do
  use Geef
  alias Eetoul.Spec.ParseError
  alias Eetoul.Spec.ValidationError
  alias Eetoul.RepoUtils

  @type t :: [(
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

  def validate repo, spec do
    case Enum.at(spec, 0) do
      {:checkout, _} -> :ok
      _ ->
        raise ValidationError, message: "First line in spec must be a `checkout`."
    end
    spec
    |> Enum.drop(1)
    |> Enum.each(fn
      {:checkout, _} ->
        raise ValidationError, message: "Cannot `checkout` twice in the same spec."
      _ -> :ok
    end)

    spec
    |> Enum.each(&(validate_line(repo, &1)))
  end

  defp validate_line repo, line do
    reference =
      (line
       |> Tuple.to_list
       |> Enum.at(1))
    # first, checking if there's such reference in the repository
    case Reference.dwim(repo, reference) do
      {:ok, _} -> :ok
      _ ->
        # second, checking if there's such a spec
        case RepoUtils.read_file(repo, "refs/heads/eetoul-spec", reference) do
          {:ok, _} -> :ok
          _ ->
            raise ValidationError, message: "Cannot find reference \"#{reference}\"."
        end
    end
  end
end
