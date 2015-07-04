defmodule Eetoul.CLIUtils do
  @doc false
  def print text, color do
    IO.write Application.get_env(:eetoul, :output_prefix, "")
    if Application.get_env :eetoul, :output_colors do
      IO.puts (Colorful.string(text, color))
    else
      IO.puts text
    end
  end
end
