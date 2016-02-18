defmodule Eetoul.Commands.Archive do
  use Eetoul.CommandDSL
  alias Eetoul.RepoUtils

  def description, do: "archives the Eetoul integration branch"

  command do
    release :release
    flag :force
  end

  def run repo, args do
    {:ok, _} = RepoUtils.commit repo, "refs/heads/eetoul-spec", "archived release \"#{args.release}\"", fn files ->
      {file, files} = Map.pop files, args.release
      Map.put files, ".archive/#{args.release}", file
    end
    IO.puts "Archived release \"#{args.release}\"."
  end
end
