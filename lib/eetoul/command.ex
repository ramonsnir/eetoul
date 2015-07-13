defmodule Eetoul.Command do
  use Behaviour

  @type argument :: (
    {:release, String.t, (:new|:existing|:archived)} |
    {:reference, String.t} |
    {:flag, String.t} |
    {:string, String.t}
  )

  @type parsed_arguments :: %{}

  @type repo :: pid

  @type validation :: (parsed_arguments -> any)

  defcallback name() :: String.t

  defcallback description() :: String.t

  defcallback arguments() :: [argument]

  defcallback validations() :: [validation]

  defcallback run(repo, parsed_arguments) :: any
end
