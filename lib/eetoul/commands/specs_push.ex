defmodule Eetoul.Commands.SpecsPush do
  use Eetoul.CommandDSL
  use Geef
  alias Eetoul.Colorful
  alias Eetoul.ManualCommands

  def description, do: "pushes the Eetoul spec branch to its default remote"

  command do
    string :remote
    flag :force
  end

  def run repo, args do
    {:ok, repo_config} = Repository.config repo
    remote =
      case Config.get_string(repo_config, "branch.eetoul-spec.remote") do
        {:ok, remote} -> remote
        {:error, "Config value 'branch.eetoul-spec.remote' was not found"} -> nil
      end
    if args[:remote] do
      if remote != nil do
        IO.puts :stderr, Colorful.string("Warning: overriding default remote #{remote}.", ~W[yellow faint]a)
      else
        Config.set repo_config, "branch.eetoul-spec.remote", args[:remote]
      end
      remote = args[:remote]
    end
    if remote == nil do
      IO.puts :stderr, Colorful.string("Cannot push without a default remote set.", ~W[red]a)
    else
      force = if args[:force] do
                "--force"
              else
                ""
              end
      ManualCommands.exec("git push #{remote} eetoul-spec #{force}")
      |> String.replace(~r/\n$/, "")
      |> IO.puts
    end
    Config.stop repo_config
    {:ok, nil}
  end
end
