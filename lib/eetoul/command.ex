defmodule Eetoul.Command do
	use Behaviour

	@type argument :: (
		{:release, String.t, (:new|:existing|:archived)} |
		{:reference, String.t} |
		{:flag, String.t} |
		{:string, String.t}
	)

	@type parsed_arguments :: any

	@type validation :: (parsed_arguments -> any)

	defcallback arguments() :: [argument]

	defcallback validations() :: [validation]

	@type command_result :: (
		:ok |
		:failure |
		{:error, any}
	)

	defcallback run(parsed_arguments) :: command_result
end
