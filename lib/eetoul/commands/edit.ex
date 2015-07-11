defmodule Eetoul.Commands.Edit do
  use Eetoul.CommandDSL

  def description, do: "opens the Eetoul spec for interactive editing"

  command do
    release :release
    flag :amend
  end
end
