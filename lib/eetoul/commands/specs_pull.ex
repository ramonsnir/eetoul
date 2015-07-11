defmodule Eetoul.Commands.SpecsPull do
  use Eetoul.CommandDSL

  def description, do: "pulls the latest Eetoul spec branch from its default remote"

  command do
    flag :force
  end
end
