defmodule Eetoul.Merge do
  use Geef
  alias Eetoul.ManualCommands
  alias Eetoul.Worktree

  def merge repo, base_commit_id, target_commit_id do
    worktree = Worktree.create repo, base_commit_id
    ManualCommands.exec(worktree, "git merge \"#{Base.encode16 target_commit_id}\"")
    result_commit_id =
      ManualCommands.exec(worktree, "git rev-parse HEAD")
    |> String.strip
    |> Base.decode16!(case: :mixed)
    :ok = Worktree.remove worktree
    {:ok, result_commit_id}
  end
end
