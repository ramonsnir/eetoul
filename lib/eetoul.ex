defmodule Eetoul do
  use Geef
  alias Eetoul.Utils
  alias Eetoul.CLI

  def main args do
    Utils.seed
    path = System.get_env("EETOUL_CWD")
    Application.put_env :eetoul, :interactive, (System.get_env("EETOUL_INTERACTIVE") == "1")
    path = path_or_default path
    Application.put_env :eetoul, :git_path, path
    case args do
      ~W[--help] -> CLI.run_command self, ~W[help]
      ~W[help] -> CLI.run_command self, ~W[help]
      _ ->
        case Repository.open path do
          {:ok, repo} -> CLI.run_command repo, args
          {:error, message} -> IO.puts :stderr, Colorful.string(message, ~W[red]a)
        end
    end
  end

  defp path_or_default path do
    if path do
      path
    else
      {:ok, p} = File.cwd
      p
    end
  end
end
