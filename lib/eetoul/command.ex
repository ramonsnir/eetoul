defmodule Eetoul.Command do
	use Behaviour

	@type argument :: (
		{:release, String.t, (:new|:existing|:archived)} |
		{:reference, String.t} |
		{:flag, String.t} |
		{:string, String.t}
	)

	@type validation :: {String.t, (Dict.t -> any)}

	defcallback arguments() :: [argument]

	defcallback validations() :: [validation]
end
