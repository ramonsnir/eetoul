defmodule Eetoul.Commands.Edit do
  use Eetoul.CommandDSL

  command do
    release :release
    flag :amend
  end
end
