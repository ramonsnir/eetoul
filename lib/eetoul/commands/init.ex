defmodule Eetoul.Commands.Init do
  use Geef
  use Eetoul.CommandDSL
  alias Eetoul.RepoUtils

  def description, do: "initialized the Eetoul spec branch"

  command do: ()

  def run repo, _args do
    {:ok, _} = RepoUtils.commit repo, "refs/heads/eetoul-spec", "initialized Eetoul spec branch", &(&1)
    IO.puts "Initialized the Eetoul spec branch."
  end
end
