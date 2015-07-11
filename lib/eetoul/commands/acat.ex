defmodule Eetoul.Commands.Acat do
  use Eetoul.CommandDSL
  require Monad.Error, as: Error
  alias Eetoul.RepoUtils

  def description, do: "prints the Eetoul spec (for an archived spec)"

  command do
    archived_release :archived_release
    flag :color
  end

  def run repo, args do
    Error.m do
      spec <- RepoUtils.read_file(repo, "refs/heads/eetoul-spec", ".archive/#{args[:archived_release]}")
      _ <- {IO.puts(String.strip(spec)), nil}
      return nil
    end
  end
end
