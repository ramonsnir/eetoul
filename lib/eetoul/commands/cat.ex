defmodule Eetoul.Commands.Cat do
  use Eetoul.CommandDSL
  alias Eetoul.Format
  alias Eetoul.RepoUtils

  def description, do: "prints the Eetoul spec"

  command do
    release :release
    flag :color
  end

  def run repo, args do
    {:ok, spec} = RepoUtils.read_file repo, "refs/heads/eetoul-spec", args.release
    Format.pretty_print spec
  end
end
