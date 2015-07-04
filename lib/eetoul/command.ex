defmodule Eetoul.Command do
	use Behaviour

	@type argument :: (
		{:release, String.t, (:new|:existing|:archived)} |
		{:reference, String.t} |
		{:flag, String.t} |
		{:string, String.t}
	)

	@type parsed_arguments :: %{}

	@type validation :: (parsed_arguments -> any)

	defcallback arguments() :: [argument]

	defcallback validations() :: [validation]

	@type command_result :: (
		{:ok, nil} |
		{:error, any}
	)

	defcallback run(parsed_arguments) :: command_result
end
