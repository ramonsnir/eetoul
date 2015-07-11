defmodule Eetoul.Commands.Test do
  use Eetoul.CommandDSL

  def description, do: "tests that the Eetoul integration branch can be made"

  command do
    release :release
  end
end
