defmodule Eetoul.Commands.Cat do
  use Eetoul.CommandDSL
  require Monad.Error, as: Error
  alias Eetoul.RepoUtils

  command do
    release :release
    flag :color
  end

  def run repo, args do
    Error.m do
      spec <- RepoUtils.read_file(repo, "refs/heads/eetoul-spec", args[:release])
      _ok <- {IO.puts(String.strip(spec)), nil}
      return nil
    end
  end
end
