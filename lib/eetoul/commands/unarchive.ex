defmodule Eetoul.Commands.Unarchive do
  use Eetoul.CommandDSL
  alias Eetoul.RepoUtils

  def description, do: "unarchives the Eetoul spec"

  command do
    archived_release :archived_release
    flag :force
  end

  def run repo, args do
    {:ok, _} =
      RepoUtils.commit repo, "refs/heads/eetoul-spec", "unarchived release \"#{args.archived_release}\"", fn files ->
      {file, files} = Map.pop files, ".archive/#{args.archived_release}"
      Map.put files, args.archived_release, file
    end
    IO.puts "Unarchived release \"#{args.archived_release}\"."
  end
end
