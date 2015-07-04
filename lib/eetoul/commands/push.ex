defmodule Eetoul.Commands.Push do
  use Eetoul.CommandDSL

  command do
    release :release
    flag :force
  end
end
