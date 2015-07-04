defmodule Eetoul.Commands.SpecsPush do
  use Eetoul.CommandDSL

  command do
    flag :force
  end
end
