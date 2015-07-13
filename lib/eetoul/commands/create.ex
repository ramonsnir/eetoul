defmodule Eetoul.Commands.Create do
  use Eetoul.CommandDSL
  alias Eetoul.RepoUtils

  def description, do: "creates a new Eetoul integration branch"

  command do
    new_release :release
    reference :base_branch
  end

  def run repo, args do
    {:ok, _} = RepoUtils.commit repo, "refs/heads/eetoul-spec", "created release \"#{args[:release]}\"", fn files ->
      Map.put files, args[:release], "checkout #{args[:base_branch]}\n"
    end
    IO.puts "Created release \"#{args[:release]}\" based on \"#{args[:base_branch]}\"."
  end
end
