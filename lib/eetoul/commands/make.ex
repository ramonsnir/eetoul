defmodule Eetoul.Commands.Make do
  use Eetoul.CommandDSL

  def description, do: "makes the Eetoul integration branch"

  command do
    release :release
  end
end
