defmodule Eetoul.Worktree do
  defstruct [:repo, :worktree_name, :worktree_path, :git_worktree_dir]

  import ShortMaps
  alias Eetoul.Worktree
  alias Eetoul.ManualCommands

  def create repo, commit_id do
    worktree_path = "/tmp/eetoul-merge-#{:random.uniform 1000000}"
    create repo, worktree_path, commit_id
  end

  def create repo, worktree_path, commit_id do
    (output = ("Preparing " <> _)) = ManualCommands.exec("git worktree add --detach \"#{worktree_path}\" #{Base.encode16(commit_id)}")
    [^worktree_path, worktree_name] =
      output
    |> String.split(["\n", "\r"], trim: true)
    |> Enum.at(0)
    |> (&(Regex.run(worktree_add_regex, &1, capture: ~W[path id]a))).()
    git_worktree_dir = ManualCommands.exec("readlink -f $(git rev-parse --git-dir)/worktrees/#{worktree_name}")
    ~m{%Worktree repo worktree_name worktree_path git_worktree_dir}a
  end

  def remove ~m{%Worktree worktree_path git_worktree_dir}a do
    File.rm_rf worktree_path
    File.rm_rf git_worktree_dir
    :ok
  end

  defp worktree_add_regex, do: ~R/^Preparing (?<path>\S+) \(identifier (?<id>[^\)]+)\)$/u
end
