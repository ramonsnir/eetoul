defmodule Eetoul.Commands.Acat do
  use Eetoul.CommandDSL
  alias Eetoul.Format
  alias Eetoul.RepoUtils

  def description, do: "prints the Eetoul spec (for an archived spec)"

  command do
    archived_release :archived_release
    flag :color
  end

  def run repo, args do
    {:ok, spec} = RepoUtils.read_file repo, "refs/heads/eetoul-spec", ".archive/#{args.archived_release}"
    Format.pretty_print spec
  end
end
