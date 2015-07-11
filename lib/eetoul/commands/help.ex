defmodule Eetoul.Commands.Help do
  use Eetoul.CommandDSL

  def description, do: "prints this message"

  command do: ()

  def run _repo, _args do
    IO.puts "Eetoul: a declarative tool for creating integration branches in git"
    IO.puts ""
    IO.puts "Available commands:"
    commands = for command <- Eetoul.CLI.commands do
      pretty_arguments = String.rstrip format_arguments(command.arguments)
      ["#{command.name} #{pretty_arguments}", command.description]
    end
    left_column_max_width =
      commands
    |> Enum.map(&(String.length(Enum.at(&1, 0))))
    |> Enum.max
    for [spec, description] <- commands do
      IO.puts "  #{String.ljust(spec, left_column_max_width + 2)}\t#{description}"
    end
    {:ok, nil}
  end

  defp format_arguments [{:release, _, _} | arguments] do
    "<release> #{format_arguments arguments}"
  end
  defp format_arguments [{:reference, _} | arguments] do
    "<git-reference> #{format_arguments arguments}"
  end
  defp format_arguments [{:options, options} | []] do
    format_options options
  end
  defp format_arguments([]), do: ""

  defp format_options [{name, :boolean} | options] do
    "[--#{name}] #{format_options options}"
  end
  defp format_options [{name, :string} | options] do
    "[--#{name} <value>] #{format_options options}"
  end
  defp format_options([]), do: ""
end
