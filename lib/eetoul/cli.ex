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

	command :init, do: ()

	command :specs_push do
		flag :force
	end

	command :specs_pull do
		flag :force
	end

	command :create do
		new_release :release
		reference :base_branch
	end

	command :make do
		release :release
	end

	command :test do
		release :release
	end

	command :push do
		release :release
		flag :force
	end

	command :add_to do
		release :release
		reference :branch
		flag :squash
		flag :merge
		string :message
		validate "--squash and --merge cannot both be specified" do
			!(opts[:squash] && opts[:merge])
		end
		validate "--message is requires if --squash or --merge are specified" do
			!((opts[:squash] || opts[:merge]) && !opts[:message])
		end
	end

	command :cat do
		release :release
		flag :color
	end
	
	command :edit do
		release :release
		flag :amend
	end

	command :help, do: ()

	defp parse_arguments repo, [{:release, name, :existing} | specs], [value | args] do
		case read_spec repo, value do
			{:ok, _} ->
				parse_arguments(repo, specs, args)
				|> Dict.put(name, value)
			_ -> raise ParseError, message: "the #{name} \"#{value}\" does not exist"
		end
	end
	defp parse_arguments repo, [{:release, name, :new} | specs], [value | args] do
		case read_spec repo, value do
			{:error, _} ->
				parse_arguments(repo, specs, args)
				|> Dict.put(name, value)
			_ -> raise ParseError, message: "the #{name} \"#{value}\" already exists"
		end
	end
	defp parse_arguments _repo, [{:release, name, _} | _], [] do
		raise ParseError, message: "no #{name} was specified"
	end

	defp parse_arguments repo, [{:reference, name} | specs], [value | args] do
		case Reference.dwim repo, value do
			{:ok, %Reference{name: real_name}} ->
				parse_arguments(repo, specs, args)
				|> Dict.put(name, real_name)
			_ -> raise ParseError, message: "the #{name} \"#{value}\" does not exist"
		end
	end
	defp parse_arguments _repo, [{:reference, name} | _], [] do
		raise ParseError, message: "no #{name} was specified"
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
