defmodule Eetoul.CLI.ParseError do
  defexception message: "Invalid arguments."
end

defmodule Eetoul.CLI do
  use Geef
  alias Eetoul.CLI.ParseError
  alias Eetoul.Colorful
  alias Eetoul.RepoUtils

  @doc ""
  def test_cli_argument_parser repo, argv do
    cli_command repo, argv, dryrun: true
  end

  @doc ""
  def run_command repo, argv do
    try do
      cli_command repo, argv
    rescue
      e in ParseError ->
        {IO.puts(:stderr, Colorful.string(e.message, :red)), nil}
    end
  end

  @external_resource commands_path = Path.join [__DIR__, "commands"]
  {:ok, command_file_names} = File.ls commands_path
  for command_file <- command_file_names do
    @external_resource Path.join [__DIR__, "commands", command_file]
  end

  @commands (command_file_names
             |> Enum.map(&(String.replace(&1, ".ex", "")))
             |> Enum.map(&(Regex.replace(~r/(?:^|_)([a-z])/, &1, (fn _, x -> String.upcase x end), [global: true]))) # converting snake_case to PascalCase
             |> Enum.sort
             |> Enum.map(&(:'Elixir.Eetoul.Commands.#{&1}')))

  def commands, do: @commands

  defp cli_command(repo, command, options \\ [])
  for command <- @commands do
    defp cli_command(repo, [unquote(Macro.escape(command.name)) | args], options) do
      spec = unquote(Macro.escape(command.arguments))
      args = parse_arguments repo, spec, args
      unquote(Macro.escape(command.validations))
      |> Enum.each(&(apply unquote(command), &1, [args]))
      if options[:dryrun] do
        args
      else
        unquote(command).run repo, args
      end
    end
  end
  defp cli_command _repo, [command | _args], _options do
    raise ParseError, message: "Unknown command \"#{command}\"."
  end
  defp cli_command _repo, [], _options do
    raise ParseError, message: "No command specified."
  end

  defp prettify_name name do
    name
    |> Atom.to_string
    |> String.replace("_", " ")
  end
  
  defp parse_arguments repo, [{:release, name, :existing} | specs], [value | args] do
    case read_spec repo, value do
      {:ok, _} ->
        parse_arguments(repo, specs, args)
        |> Dict.put(name, value)
      _ -> raise ParseError, message: "The #{prettify_name name} \"#{value}\" does not exist."
    end
  end
  defp parse_arguments repo, [{:release, name, :new} | specs], [value | args] do
    case read_spec repo, value do
      {:error, _} ->
        parse_arguments(repo, specs, args)
        |> Dict.put(name, value)
      _ -> raise ParseError, message: "The #{prettify_name name} \"#{value}\" already exists."
    end
  end
  defp parse_arguments repo, [{:release, name, :archived} | specs], [value | args] do
    case read_spec repo, ".archive/#{value}" do
      {:ok, _} ->
        parse_arguments(repo, specs, args)
        |> Dict.put(name, value)
      _ -> raise ParseError, message: "The #{prettify_name name} \"#{value}\" does not exist."
    end
  end
  defp parse_arguments _repo, [{:release, name, _} | _], [] do
    raise ParseError, message: "No #{prettify_name name} was specified."
  end

  defp parse_arguments repo, [{:reference, name} | specs], [value | args] do
    case Reference.dwim repo, value do
      {:ok, %Reference{name: real_name}} ->
        value = String.split(real_name, "/") |> Enum.reverse |> Enum.at(0)
        parse_arguments(repo, specs, args)
        |> Dict.put(name, value)
      _ -> raise ParseError, message: "The #{prettify_name name} \"#{value}\" does not exist."
    end
  end
  defp parse_arguments _repo, [{:reference, name} | _], [] do
    raise ParseError, message: "No #{prettify_name name} was specified."
  end

  defp parse_arguments repo, [{:options, spec} | []], args do
    case OptionParser.parse(args, strict: spec) do
      {options, [], []} -> Enum.into options, parse_arguments(repo, [], [])
      {_options, _argv, _errors} -> raise ParseError
    end
  end
  defp parse_arguments _repo, [{:options, _spec} | _], _args do
    raise ParseError, message: ":options must be the last arguments specification."
  end

  defp parse_arguments(_repo, [], []), do: %{}
  defp parse_arguments _repo, [], [arg | _args] do
    raise ParseError, message: "Invalid arguments starting with #{arg}."
  end

  defp read_spec repo, spec do
    RepoUtils.read_file repo, "refs/heads/eetoul-spec", spec
  end
end
