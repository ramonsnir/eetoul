defmodule Eetoul.ManualCommands do
  import ShortMaps
  alias Eetoul.Worktree

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
    :os.cmd('cd "#{wd}" && #{command}')
    |> List.to_string
  end
end
