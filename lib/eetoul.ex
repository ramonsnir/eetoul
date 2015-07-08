defmodule Eetoul do
  use Geef
  alias Eetoul.CLI

  def main args do
    path = System.get_env("EETOUL_CWD")
    if path == nil do
      {:ok, path} = File.cwd
    end
    {:ok, repo} = Repository.open path
    CLI.run_command repo, args, interactive: (System.get_env("EETOUL_INTERACTIVE") == "1")
  end
end
