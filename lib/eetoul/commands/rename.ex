defmodule Eetoul.Commands.Rename do
  use Eetoul.CommandDSL
  alias Eetoul.RepoUtils

  def description, do: "renames the Eetoul integration branch"

  command do
    release :release
    new_release :new_name
  end

  def run repo, args do
    {:ok, _} = RepoUtils.commit repo, "refs/heads/eetoul-spec", "renamed \"#{args[:release]}\" to \"#{args[:new_name]}\"", fn files ->
      files
      |> Map.put(args[:new_name], files[args[:release]])
      |> Map.delete(args[:release])
    end
    IO.puts "Renamed \"#{args[:release]}\" to \"#{args[:new_name]}\"."
  end
end
