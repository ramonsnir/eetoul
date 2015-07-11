defmodule Eetoul.Commands.Init do
  use Geef
  use Eetoul.CommandDSL
  require Monad.Error, as: Error
  alias Eetoul.RepoUtils

  def description, do: "initialized the Eetoul spec branch"

  command do: ()

  def run repo, _args do
    Error.m do
      _commit <- RepoUtils.commit repo, "refs/heads/eetoul-spec", "initialized Eetoul spec branch", &({:ok, &1})
      _ok <- {IO.puts("Initialized the Eetoul spec branch."), nil}
      return nil
    end
  end
end
