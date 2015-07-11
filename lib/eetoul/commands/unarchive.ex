defmodule Eetoul.Commands.Unarchive do
  use Eetoul.CommandDSL
  require Monad.Error, as: Error
  alias Eetoul.RepoUtils

  def description, do: "unarchives the Eetoul spec"

  command do
    archived_release :archived_release
    flag :force
  end

  def run repo, args do
    Error.m do
      _commit <- RepoUtils.commit repo, "refs/heads/eetoul-spec", "unarchived release \"#{args[:archived_release]}\"", fn files ->
        {file, files} = Map.pop files, ".archive/#{args[:archived_release]}"
        {:ok, Map.put(files, args[:archived_release], file)}
      end
      _ok <- {IO.puts("Unarchived release \"#{args[:archived_release]}\"."), nil}
      return nil
    end
  end
end
