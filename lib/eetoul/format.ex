defmodule Eetoul.Format do
  alias Eetoul.Colorful

  @doc ""
  def pretty_print device \\ :stdio, spec do
    spec
    |> String.split(["\r", "\n"], trim: true)
    |> Enum.map(&(String.split(&1, "#")))
    |> Enum.map(&(if Enum.count(&1) == 1, do: [Enum.at(&1, 0), nil], else: &1))
    |> Enum.each(fn [code, comment] ->
      code = String.strip code
      if code != "" do
        [command, reference, message] =
          case String.split(code, " ", parts: 3, trim: true) do
            [command] -> [command, nil, nil]
            [command, reference] -> [command, reference, nil]
            all -> all
          end
        IO.write device, Colorful.string(command, [:default_color])
        if reference do
          IO.write device, " "
          IO.write device, Colorful.string(reference, [:green, :bright])
        end
        if message do
          IO.write device, " "
          IO.write device, Colorful.string(message, [:default_color])
        end
      end
      if comment != nil do
        if code != "" do
          IO.write device, " "
        end
        IO.write device, Colorful.string("##{comment}", [:green, :faint])
      end
      IO.puts device, ""
    end)
  end
end
