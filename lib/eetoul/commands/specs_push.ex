defmodule Eetoul.Commands.SpecsPush do
  use Eetoul.CommandDSL
  use Geef
  alias Eetoul.Colorful
  alias Eetoul.ManualCommands
  alias Eetoul.RecordedConflictResolutions

  def description, do: "pushes the Eetoul spec branch to its default remote"

  command do
    string :remote
    flag :force
  end

  def run repo, args do
    {:ok, repo_config} = Repository.config repo
    remote =
      case Config.get_string(repo_config, "branch.eetoul-spec.remote") do
        {:ok, r} -> r
        {:error, "Config value 'branch.eetoul-spec.remote' was not found"} -> nil
      end
    remote =
    if args[:remote] do
      if remote != nil do
        IO.puts :stderr, Colorful.string("Warning: overriding default remote #{remote}.", ~W[yellow faint]a)
      else
        Config.set repo_config, "branch.eetoul-spec.remote", args[:remote]
      end
      args[:remote]
    else
      remote
    end
    if remote == nil do
      IO.puts :stderr, Colorful.string("Cannot push without a default remote set.", ~W[red]a)
    else
      force = if args[:force] do
        "--force"
      else
        ""
      end
      ManualCommands.exec!("git push #{remote} eetoul-spec #{RecordedConflictResolutions.rcr_branch} #{force}")
      |> String.replace(~r/\n$/, "")
      |> IO.puts
    end
    Config.stop repo_config
    {:ok, nil}
  end
end
