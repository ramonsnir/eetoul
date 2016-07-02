defmodule Eetoul.RecordedConflictResolutions do
  use Geef
  alias Eetoul.RepoUtils
  require Monad.Error, as: Error

  @strategies [:exact]

  @doc ""
  def reapply_recorded_resolutions repo, rcr_key, ref, base_commit, ref_commit do
    Enum.reduce @strategies, {:error, :no_rcr_strategies}, fn strategy, result ->
      case result do
        {:ok, _} -> result
        _ ->
          try_strategy strategy, repo, rcr_key, ref, base_commit, ref_commit
      end
    end
  end

  @doc ""
  def rcr_branch, do: "eetoul-recorded-conflict-resolutions"

  @doc ""
  def rcr_reference, do: "refs/heads/#{rcr_branch}"

  defp try_strategy :exact, repo, rcr_key, ref, base_commit, ref_commit do
    recorded_resolution_path = "#{rcr_key}/exact/#{ref}/#{Base.encode16 base_commit}/#{Base.encode16 ref_commit}"
    Error.m do
      commit_id <- RepoUtils.read_file repo, rcr_reference, recorded_resolution_path
      _commit <- Commit.lookup repo, commit_id # verifying that commit is available in ODB
      return commit_id
    end
  end
end
