defmodule Eetoul.Commands.Cat do
  use Eetoul.CommandDSL
  require Monad.Error, as: Error
  alias Eetoul.RepoUtils

  def description, do: "prints the Eetoul spec"

  command do
    release :release
    flag :color
  end

  def run repo, args do
    Error.m do
      spec <- RepoUtils.read_file(repo, "refs/heads/eetoul-spec", args[:release])
      _ok <- {IO.write(spec), nil}
      return nil
    end
  end
end
