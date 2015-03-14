defmodule Eetoul.CLI.ParseError do
	defexception message: "invalid arguments"
end

defmodule Eetoul.CLI do
	use Geef
	require Monad.Error, as: Error
	use Eetoul.CLIDSL
	alias Eetoul.CLI.ParseError

	@doc false
	def test_cli_argument_parser repo, argv do
		cli_command repo, argv, dryrun: true
	end

	command :edit do
		release :release
		flag :amend
	end

	defp parse_arguments repo, [{:release, name, mode} | specs], [value | args] do
		case {mode, read_spec(repo, value)} do
			{:existing, {:ok, _}} ->
				parse_arguments(repo, specs, args)
				|> Dict.put(name, value)
			_ -> raise ParseError, message: "the #{name} \"#{value}\" does not exist"
		end
	end
	defp parse_arguments _repo, [{:release, spec, _} | _], [] do
		raise ParseError, message: "no #{spec} was specified"
	end
	defp parse_arguments repo, [{:options, spec} | []], args do
		case OptionParser.parse(args, strict: spec) do
			{options, [], []} -> Enum.into options, parse_arguments(repo, [], [])
			{_options, _argv, _errors} -> raise ParseError
		end
	end
	defp parse_arguments _repo, [{:options, _spec} | _], _args do
		raise ParseError, message: ":options must be the last arguments specification"
	end
	defp parse_arguments(_repo, [], []), do: %{}
	defp parse_arguments _repo, [], [arg | _args] do
		raise ParseError, message: "invalid arguments starting with #{arg}"
	end

	defp run_command repo, name, data do
		# TODO implement
		IO.inspect {repo, name, data}
	end

	def read_spec repo, spec do
		Error.m do
			%Reference{target: commit_id} <- Reference.lookup(repo, "refs/heads/eetoul-spec")
			commit <- Commit.lookup(repo, commit_id)
			tree <- Commit.tree(commit)
			%TreeEntry{id: file_id} <- Tree.get(tree, spec)
			blob <- Blob.lookup(repo, file_id)
			content <- Blob.content(blob)
			return content
		end
	end
end
