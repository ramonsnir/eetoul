defmodule Eetoul.Commands.Acat do
  use Eetoul.CommandDSL

  command do
    archived_release :release
    flag :color
  end
end
