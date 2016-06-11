defmodule Eetoul.ManualCommands do
  import ShortMaps
  alias Eetoul.Worktree

  @doc ""
  def exec! command do
    {:ok, output} = exec command
    output
  end

  @doc ""
  def exec! wd, command do
    {:ok, output} = exec wd, command
    output
  end

  @doc ""
  def exec command do
    git_path = Application.get_env :eetoul, :git_path
    do_exec git_path, command
  end

  @doc ""
  def exec ~m{%Worktree worktree_path}a, command do
    do_exec worktree_path, command
  end

  defp do_exec wd, command do
    [exit_code_string | output_lines_reversed] =
      :os.cmd('(cd "#{wd}" && #{command}); echo -n "\n$?"')
    |> List.to_string
    |> String.split("\n")
    |> Enum.reverse
    if exit_code_string == "0" do
      {:ok,
       output_lines_reversed
       |> Enum.reverse
       |> Enum.join("\n")}
    else
      :error
    end
  end
end
