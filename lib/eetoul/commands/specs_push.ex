defmodule Eetoul.Commands.SpecsPush do
  use Eetoul.CommandDSL

  def description, do: "pushes the Eetoul spec branch to its default remote"

  command do
    string :remote
    flag :force
  end
end
