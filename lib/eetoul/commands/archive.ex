defmodule Eetoul.Commands.Archive do
  use Eetoul.CommandDSL
  require Monad.Error, as: Error
  alias Eetoul.RepoUtils

  def description, do: "archives the Eetoul integration branch"

  command do
    release :release
    flag :force
  end

  def run repo, args do
    Error.m do
      _commit <- RepoUtils.commit repo, "refs/heads/eetoul-spec", "archived release \"#{args[:release]}\"", fn files ->
        {file, files} = Map.pop files, args[:release]
        {:ok, Map.put(files, ".archive/#{args[:release]}", file)}
      end
      _ok <- {IO.puts("Archived release \"#{args[:release]}\"."), nil}
      return nil
    end
  end
end
