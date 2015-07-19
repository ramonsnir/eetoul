defmodule Eetoul.Commands.Rename do
  use Eetoul.CommandDSL
  alias Eetoul.RepoUtils

  def description, do: "renames the Eetoul integration branch"

  command do
    release :release
    new_release :new_name
    flag :unsafe
  end
end
