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
    {:take, String.t, ({:squash, String.t} | :merge | :rebase)}
  )]

  def parse spec do
    spec
    |> String.split(["\n", "\r"], trim: true)
    |> Enum.map(&(String.split(&1, "#")))
    |> Enum.map(&(Enum.at(&1, 0)))
    |> Enum.map(&parse_line/1)
    |> Enum.map(fn {a, b, c} -> validate_and_translate_line a, b, c end)
  end

  def parse_line line do
    case String.split(line, " ", parts: 3, trim: true) do
      [command] -> {command, nil, nil}
      [command, reference] -> {command, reference, nil}
      all -> List.to_tuple all
    end
  end

  defp validate_and_translate_line command, reference, message do
    case command do
      "checkout" ->
        validate_argument command, :reference, reference, true
        validate_argument command, :message, message, false
        {:checkout, reference}
      "take" ->
        validate_argument command, :reference, reference, true
        validate_argument command, :message, message, true
        {:take, reference, {:squash, message}}
      "take-merge" ->
        validate_argument command, :reference, reference, true
        validate_argument command, :message, message, false
        {:take, reference, :merge}
      "take-rebase" ->
        validate_argument command, :reference, reference, true
        validate_argument command, :message, message, false
        {:take, reference, :rebase}
    end
  end

  defp validate_argument command, arg_name, arg_value, required do
    if arg_value == nil && required do
      raise ParseError, message: "`#{command}` expects a #{arg_name} argument."
    end
    if arg_value != nil && !required do
      raise ParseError, message: "`#{command}` does not expect a #{arg_name} argument."
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
