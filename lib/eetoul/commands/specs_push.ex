defmodule Eetoul.Commands.SpecsPush do
  use Eetoul.CommandDSL
  alias Eetoul.Colorful
  alias Eetoul.ManualCommands

  def description, do: "pushes the Eetoul spec branch to its default remote"

  command do
    string :remote
    flag :force
  end

  def run _repo, args do
    remote = String.strip ManualCommands.exec("git config --get branch.eetoul-spec.remote")
    if args[:remote] do
      if remote != "" do
        IO.puts :stderr, Colorful.string("Warning: overriding default remote #{remote}.", [:yellow, :faint])
      else
        ManualCommands.exec("git config --set branch.eetoul-spec.remote #{remote}")
      end
      remote = args[:remote]
    end
    if remote == "" do
      IO.puts :stderr, Colorful.string("Cannot push without a default remote set.", :red)
    else
      force = if args[:force] do
                "--force"
              else
                ""
              end
      IO.write ManualCommands.exec("git push #{remote} eetoul-spec #{force}")
    end
    {:ok, nil}
  end
end
