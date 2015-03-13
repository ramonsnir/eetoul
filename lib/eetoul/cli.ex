defmodule Eetoul.CLI.ParseError do
	defexception message: "invalid arguments"
end

defmodule Eetoul.CLI do
	use Eetoul.CLIDSL
	alias Eetoul.CLI.ParseError

	@doc false
	def test_cli_argument_parser argv do
		cli_command argv, dryrun: true
	end

	command :edit do
		release :release
		flag :amend
	end

	defp parse_arguments([{:release, name} | specs], [value | args]) do
		parse_arguments(specs, args)
		|> Dict.put(name, value)
	end
	defp parse_arguments([{:release, spec} | _], []) do
		raise ParseError, message: "no #{spec} was specified"
	end
	defp parse_arguments([{:options, spec} | []], args) do
		case OptionParser.parse(args, strict: spec) do
			{options, [], []} -> Enum.into options, parse_arguments([], [])
			{_options, _argv, _errors} -> raise ParseError
		end
	end
	defp parse_arguments([{:options, _spec} | _], _args) do
		raise ParseError, message: ":options must be the last arguments specification"
	end
	defp parse_arguments([], []), do: %{}
	defp parse_arguments([], [arg | _args]) do
		raise ParseError, message: "invalid arguments starting with #{arg}"
	end

	defp run_command name, data do
		# TODO implement
		IO.inspect {name, data}
	end
end
