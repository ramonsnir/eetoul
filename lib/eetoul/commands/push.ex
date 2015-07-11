defmodule Eetoul.Commands.Push do
  use Eetoul.CommandDSL

  def description, do: "makes and pushes the Eetoul integration branch"

  command do
    release :release
    flag :force
  end
end
