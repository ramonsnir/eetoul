defmodule Eetoul.CLIDSL do
	@doc false
	defmacro __using__ _opts do
		quote do
			import Eetoul.CLIDSL

			@before_compile Eetoul.CLIDSL

			defp cli_command(repo, command, options \\ [])
		end
	end

	@doc false
	defmacro __before_compile__(_env) do
		quote do
			defp cli_command repo, command, _options do
				raise Eetoul.CLI.ParseError, message: "unknown command #{command}"
			end
		end
	end

	@doc false
	defmacro command name, do: block do
		command_name = String.replace(Atom.to_string(name), "_", "-")
		quote do
			defp cli_command repo, [unquote(command_name) | args], options do
				if options[:dryrun] do
					var!(run) = fn args -> args end
				else
					var!(run) = fn args -> run_command repo, unquote(name), args end
				end
				var!(arguments) = []
				unquote block
				var!(arguments)
				|> Enum.reverse
				|> (fn specs -> parse_arguments(repo, specs, args) end).()
				|> var!(run).()
			end
		end
	end

	@doc false
	defmacro release name do
		quote do
			var!(arguments) = [{:release, unquote(name), :existing} | var!(arguments)]
		end
	end

	@doc false
	defmacro new_release name do
		quote do
			var!(arguments) = [{:release, unquote(name), :new} | var!(arguments)]
		end
	end

	@doc false
	defmacro reference name do
		quote do
			var!(arguments) = [{:reference, unquote(name)} | var!(arguments)]
		end
	end

	@doc false
	defmacro flag name do
		quote do
			var!(arguments) = case var!(arguments) do
													[{:options, options} | rest] ->
														[{:options, [{unquote(name), :boolean} | options]} | rest]
													rest -> [{:options, [{unquote(name), :boolean}]} | rest]
												end
		end
	end
end
