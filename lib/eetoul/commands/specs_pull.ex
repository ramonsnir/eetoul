defmodule Eetoul.Commands.SpecsPull do
  use Eetoul.CommandDSL
  alias Eetoul.Colorful

  def description, do: "pulls the latest Eetoul spec branch from its default remote"

  command do
    string :remote
    flag :force
  end

  def run _repo, _args do
    IO.puts :stderr, Colorful.string("Not implemented.", ~W[red])
  end
end
