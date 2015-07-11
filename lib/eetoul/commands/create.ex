defmodule Eetoul.Commands.Create do
  use Eetoul.CommandDSL
  require Monad.Error, as: Error
  alias Eetoul.RepoUtils

  command do
    new_release :release
    reference :base_branch
  end

  def run repo, args do
    Error.m do
      _commit <- RepoUtils.commit repo, "refs/heads/eetoul-spec", "created release \"#{args[:release]}\"", fn files ->
        {:ok, Map.put(files, args[:release], "checkout #{args[:base_branch]}\n")}
      end
      _ok <- {IO.puts("Created release \"#{args[:release]}\" based on \"#{args[:base_branch]}\"."), nil}
      return nil
    end
  end
end
