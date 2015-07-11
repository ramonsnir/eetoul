defmodule Eetoul.Commands.Cat do
  use Eetoul.CommandDSL
  require Monad.Error, as: Error
  alias Eetoul.Format
  alias Eetoul.RepoUtils

  def description, do: "prints the Eetoul spec"

  command do
    release :release
    flag :color
  end

  def run repo, args do
    Error.m do
      spec <- RepoUtils.read_file(repo, "refs/heads/eetoul-spec", args[:release])
      _ok <- {:ok, Format.pretty_print(spec)}
      return nil
    end
  end
end
