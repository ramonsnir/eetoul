defmodule Eetoul do
  use Geef
  alias Eetoul.CLI

  def main args do
    path = System.get_env("EETOUL_CWD")
    Application.put_env :eetoul, :interactive, (System.get_env("EETOUL_INTERACTIVE") == "1")
    if path == nil do
      {:ok, path} = File.cwd
    end
    case args do
      ["--help"] -> CLI.run_command self, ["help"]
      ["help"] -> CLI.run_command self, ["help"]
      _ ->
        Application.put_env :eetoul, :git_path, path
        case Repository.open path do
          {:ok, repo} -> CLI.run_command repo, args
          {:error, message} -> IO.puts :stderr, Colorful.string(message, :red)
        end
    end
  end
end
