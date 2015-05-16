defmodule Eetoul.CommandDSL do
	@doc false
	defmacro __using__ _opts do
		quote do
			@behaviour Eetoul.Command

			import Eetoul.CommandDSL

			def name do
				# in PascalCase
				command_name = 
					__MODULE__
				|> Atom.to_string
				|> String.split(".")
				|> Enum.reverse
				|> Enum.fetch!(0)
				# converting PascalCase to lisp-case
				Regex.replace(~r/([a-z])([A-Z])/, command_name,
											"\\1-\\2", [global: true])
				|> String.downcase
			end
		end
	end

	@doc false
	defmacro command do: block do
		quote do
			def arguments do
				var!(args) = []
				unquote block
				var!(args) |> Enum.reverse
			end

			def validations do
				[]
			end
		end
	end

	@doc false
	defmacro release name do
		quote do
			var!(args) = [{:release, unquote(name), :existing} | var!(args)]
		end
	end

	@doc false
	defmacro new_release name do
		quote do
			var!(args) = [{:release, unquote(name), :new} | var!(args)]
		end
	end

	@doc false
	defmacro archived_release name do
		quote do
			var!(args) = [{:release, unquote(name), :archived} | var!(args)]
		end
	end

	@doc false
	defmacro reference name do
		quote do
			var!(args) = [{:reference, unquote(name)} | var!(args)]
		end
	end

	@doc false
	defmacro flag name do
		quote do
			var!(args) = case var!(args) do
										 [{:options, options} | rest] ->
											 [{:options, [{unquote(name), :boolean} | options]} | rest]
										 rest -> [{:options, [{unquote(name), :boolean}]} | rest]
									 end
		end
	end

	@doc false
	defmacro string name do
		quote do
			var!(args) = case var!(args) do
										 [{:options, options} | rest] ->
											 [{:options, [{unquote(name), :string} | options]} | rest]
										 rest -> [{:options, [{unquote(name), :string}]} | rest]
									 end
		end
	end

	@doc false
	defmacro validate error_message, do: block do
		quote do
			var!(validations) = [fn opts ->
														var!(opts) = opts
														unless unquote(block) do
															raise ParseError, message: unquote(error_message)
														end
													end | var!(validations)]
		end
	end
end
