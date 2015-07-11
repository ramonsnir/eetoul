defmodule Eetoul.Commands.SpecsPull do
  use Eetoul.CommandDSL

  def description, do: "pulls the latest Eetoul spec branch from its default remote"

  command do
    string :remote
    flag :force
  end
end
