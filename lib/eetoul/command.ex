defmodule Eetoul.Command do
	use Behaviour

	@type argument :: (
		{:release, String.t, (:new|:existing|:archived)} |
		{:reference, String.t} |
		{:flag, String.t} |
		{:string, String.t}
	)

	@type spec :: any

	@type validation :: (spec -> any)

	defcallback arguments() :: [argument]

	defcallback validations() :: [validation]

	#defcallback run(spec) :: boolean
end
