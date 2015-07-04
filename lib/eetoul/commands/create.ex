defmodule Eetoul.Commands.Create do
  use Eetoul.CommandDSL

  command do
    new_release :release
    reference :base_branch
  end
end
